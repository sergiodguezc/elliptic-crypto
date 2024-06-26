/*
    DIFFERENT ALGORITHMS TO TACKLE THE DISCRETE LOGARITHM PROBLEM

    Author: Sergio Domínguez Cabrera
*/

// Imports
load "utils.m";

// ============================================================================
//              NAIVE SEARCH
// ============================================================================

// Naive search for discrete logarithm
function NaiveSearch(G, n, P)
    for k in [0..n-1] do
        if k*G eq P then
            return k;
        end if;
    end for;
end function;

// ============================================================================
//              BABY STEP GIANT STEP
// ============================================================================


/* Baby Step Giant Step Algorithm
 * @param G: Base point (Generator of <G>)
 * @param n: Order of G
 * @param P: P in <G>
 * @output k: satisfying P = k * G
*/
function BabyStepGiantStep(G, n, P)
    m := Ceiling(Sqrt(n));

    table := {@  j * G : j in [0..m-1] @};
    mGInv := (- m) * G;
    gamma := P;

    for i in [0..m-1] do
        if gamma in table then
            idx := Index(table, gamma) - 1;
            return i*m + idx;
        else
            gamma +:= mGInv;
        end if;
    end for;

end function;

// ============================================================================
//              POLLARD'S RHO ALGORITHM
// ============================================================================


// Auxiliary procedure
procedure NewBxy(~B, ~x, ~y, P, G, n)
    case (Integers() ! B[1]) mod 3:
        when 0:
            B := 2 * B;
            x := x * 2 mod n;
            y := y * 2 mod n;
        when 1:
            B := B + G;
            x := (x + 1) mod n;
        when 2:
            B := B + P;
            y := (y + 1) mod n;
    end case;
end procedure;


/* Pollard's rho algorithm
   @param E: Elliptic curve
   @param G: Generator point
   @param n: Order of G
   @param P: P in <G>, i.e. P = kG
   @output: k such that P = kG
*/
function ECPollardRho(G, n, P)
    E := Curve(G);
    p := #BaseRing(E);

    while true do
        x := Random([1.. n - 1]);
        X := x;
        y := 0; Y := y;
        b := x * G; B := b; 


        // printf "%3o  %15o %10o %3o  %15o %10o %3o\n", "i", "b", "x", "y", "B", "X", "Y";
        for i in [1..n-1] do
            NewBxy(~b, ~x, ~y, P, G, n);
            NewBxy(~B, ~X, ~Y, P, G, n);
            NewBxy(~B, ~X, ~Y, P, G, n);
            // printf "%3o  %15o %10o %3o  %15o %10o %3o\n", i, b, x, y, B, X, Y;

            if x * G + y * P ne b then
                print "Error! xG + yP != b";
            end if;

            if X * G + Y * P ne B then
                print "Error! XG + YP != B";
            end if;

            if b eq B then
                break;
            end if;
        end for;

        // Calculate g := gcd(Y - y, n)
        // if ((Y - y) mod n) ne 0 then
            g := GCD(Y - y, n);

            // If g divides (x - X) then we have a solution
            if ((x - X) mod g) eq 0 then
                // Check if (Y - y)/g and n are coprime
                if GCD((Y - y) div g, n) eq 1 then
                    z := Modinv((Y - y) div g, n) * ((x - X) div g) mod n;
                    zs := [ z + k * (n div g) : k in [0..g-1] ];

                    if exists(k) { k: k in zs | k * G eq P } then
                        return k;
                    else
                        print "Error! No solution found!"; // Should never happen
                    end if;
                end if;
                
            end if;
        //end if;

    end while;

    print "Error! No solution found!";
end function;


// ============================================================================
//              POHLIG-HELLMAN ALGORITHM
// ============================================================================

/* Solve the small DL problem in a prime power group
   @param G: Generator point
   @params p, e: order of G = p^e
   @param P: P in <G>, i.e. P = kG
   @return: k such that P = kG
*/
function PohligHellmanPrimeTower(G, pe,  P, pollard)
    p := pe[1]; e := pe[2];
    n  := p^e;
    x := 0;
    gamma := Modexp(p,(e - 1), n) * G; // This element has order p, p * gamma = 0

    for k in [0..e-1] do
        tk := Modexp(p,e - 1 - k, n);

        hk := tk * ((-x)*G + P);

        if pollard and p gt 3 then
            dk := ECPollardRho(gamma, p, hk);
        else
            dk := BabyStepGiantStep(gamma, p, hk);
        end if;
        x := x + dk * (p^k);
    end for;

    return x;
end function;


/* Pohlig-Hellman Algorithm for solving the Discrete Logarithm Problem
   @param E: elliptic curve
   @param G: base point
   @param ordG: order of G
   @param P: P in <G> 
   @return: l such that P = lQ
*/
function PohligHellman(G, ordG, P, pollard)
    // Step 1: Factorize the order of G
    factors := Factorization(ordG);
    
    Gs := [ (ordG div (f[1]^f[2])) * G : f in factors ];
    Ps := [ (ordG div (f[1]^f[2])) * P : f in factors ];

    xi := [ PohligHellmanPrimeTower(Gs[i], factors[i], Ps[i], pollard) : i in [1..#factors] ];

    pe := [ pe[1]^pe[2] : pe in factors ];

    return SolveCongruences(xi, pe);
end function;
