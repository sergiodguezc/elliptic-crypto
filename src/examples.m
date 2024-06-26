/* 
    EXAMPLES

    Author: Sergio Domínguez Cabrera
*/

load "ecdsa.m";
load "elliptic.m";
load "naive_elliptic.m";
load "attacks.m";

procedure show_menu()
    print "\n  == OPTIONS ==";
    print " 1. Sign a message";
    print " 2. Verify a signature";
    print " 3. Print parameters";
    print " 4. Attack";
    print " 5. Exit\n";
end procedure;

procedure print_curve_parameters(E, G, n)
    print " == Curve Parameters ==";
    print " +", E;
    print " + Base Point G: ", G;
    print " + ord(G): ", n;
    print "";
end procedure;

procedure print_key_pairs(ad, aQ, bd, bQ)
    print " == Key Pairs ==";
    print " + Alice ";
    print "   - Private key d: ", ad;
    print "   - Public key Q: ", aQ;
    print " + Bob ";
    print "   - Private key d: ", bd;
    print "   - Public key Q: ", bQ;
end procedure;

procedure sign_message(G, n, ad, aQ, bd, bQ, ~ms)
    read who, " Who is sending the message? (Alice/Bob): ";

    if who eq "Alice" then
        read m, " Message: ";
        r, s := Sign(m , G, n, ad);
        Append(~ms, <m, r, s>);
    elif who eq "Bob" then
        read m, " Message: ";
        r, s := Sign(m , G, n, bd);
        Append(~ms, <m, r, s>);
    else
        print "Invalid option!";
    end if;
end procedure;

procedure verify_signature(ms, E, G, n, aQ, bQ)
    if #ms eq 0 then
        print "No messages. Sign a message first!";
    else
        print "  Signed Messages ";
        for i in [1..#ms] do
            print "  + Message ", i; 
            print "   m :", ms[i][1];
            print "   r :", ms[i][2];
            print "   s :", ms[i][3];
        end for;

        readi idx, " Message index: ";
        if idx gt #ms or idx le 0 then
            print "Invalid index!";
        else
            m := ms[idx][1];
            r := ms[idx][2];
            s := ms[idx][3];
            read who, " Whose signature do you want to verify? (Alice/Bob): ";
            if who eq "Alice" then
                res := Verify(m, r, s, G, n, aQ);
                if res then
                    print "Signature is valid!";
                else
                    print "Signature is invalid!";
                end if;
            elif who eq "Bob" then
                res := Verify(m, r, s, G, n, bQ);
                if res then
                    print "Signature is valid!";
                else
                    print "Signature is invalid!";
                end if;
            else
                print "Invalid option!";
            end if;
        end if;
    end if;
end procedure;

procedure perform_attack(E, G, n, aQ, bQ, ad, bd)
    read who, " Who do you want to attack? (Alice/Bob): ";
    if who eq "Alice" then
        key := aQ;
        private_key := ad;
    elif who eq "Bob" then
        key := bQ;
        private_key := bd;
    else
        print "Invalid option!";
        return;
    end if;

    print " Which attack do you want to perform? : ";
    print "    1. Naive Search";
    print "    2. Baby-Step Giant-Step";
    print "    3. Pollard's Rho";
    print "    4. Pohlig-Hellman";
    readi type, "Option (index)";

    if type eq 1 then
        print " -> Wait while we perform the attack...";
        k := NaiveSearch(G, n, key);
    elif type eq 2 then
        print " -> Wait while we perform the attack...";
        k := BabyStepGiantStep(G, n, key);
    elif type eq 3 then
        print " -> Wait while we perform the attack...";
        k := ECPollardRho(G, n, key);
    elif type eq 4 then
        print " How do you want to solve the small discrete logarithm problem?";
        print "    1. Baby Step Giant Step (default)";
        print "    2. Pollard's Rho ";
        read how, "Option (index)";
        if how eq "2" then
            print " -> Wait while we perform the attack...";
            k := PohligHellman(G, n, key, true);
        else
            print " -> Wait while we perform the attack...";
            k := PohligHellman(G, n, key, false);
        end if;
    else
        print "Invalid attack type!";
        return;
    end if;
    
    print " -> Attack finished!";
    print "   - Private key d: ", private_key;
    print "   - Found key:     ", k;
end procedure;

procedure example_ecdsa(E, G, n)
    print " -> Curve parameters generated!\n";
    print " -> Wait while we generate the key pairs for Alice and Bob...";
    ad, aQ := GenerateKeyPair(G, n);
    bd, bQ := GenerateKeyPair(G, n);
    print " -> Key pair generated!\n";

    exit_cond := false;
    ms := [];

    while not exit_cond do
        show_menu();
        read opt, " Option: ";

        if opt eq "1" then
            sign_message(G, n, ad, aQ, bd, bQ, ~ms);

        elif opt eq "2" then
            verify_signature(ms, E, G, n, aQ, bQ);

        elif opt eq "3" then
            print_curve_parameters(E, G, n);
            print_key_pairs(ad, aQ, bd, bQ);

        elif opt eq "4" then
            perform_attack(E, G, n, aQ, bQ, ad, bd);

        elif opt eq "5" then
            exit_cond := true;
        else
            print "Invalid option!";
        end if;
    end while;
end procedure;

// Call examples with appropriate parameters
procedure secure_example()
    print "\n ========== ECDSA SECURE EXAMPLE ==========\n";
    print " -> Wait while we generate the curve...";

    // Generation of the shared parameters for the signature scheme
    E, G, n := CryptoCurve(200);

    example_ecdsa(E, G, n);
end procedure;

procedure small_example()
    print "\n ========== ECDSA SMALL EXAMPLE ==========\n";
    print " -> Wait while we generate the curve...";

    // Generation of the shared parameters for the signature scheme
    E, G, n := NaiveECParams(30);

    example_ecdsa(E, G, n);
end procedure;

procedure smooth_example()
    print "\n ========== ECDSA SMOOTH EXAMPLE ==========\n";
    print " -> Wait while we generate the curve...";

    // Generation of the shared parameters for the signature scheme
    // E, G, n := SmoothECParams(80, 30);

    E := EllipticCurve([GF(1011491296287123321718725547293672692111) | 719319513746953810125148989197365939068,976521736510223101383449160650782996352]);
    G := E ! [634386635828998137316432388680355026541, 866672159324879821297486223275464261444];
    n := 1011491296287123321699999259996068234286;

    example_ecdsa(E, G, n);
end procedure;

