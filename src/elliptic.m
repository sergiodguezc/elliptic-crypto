/* 
    ELLIPTIC CURVE GENERATION (SECURE IMPLEMENTATION)

    Author: Sergio Domínguez Cabrera
*/

// Imports
load "utils.m";


/* GENERATING A RANDOM ELLIPTIC CURVE OVER Fp.
* @param F: Finite field Fp (p prime)
* @param OrderBound: Lower bound for the order of the elliptic curve
* @output F: Verifible random elliptic curve over Fp
*/
function RandomECFp(F, OrderBound)
    p := #F;

    if p lt OrderBound then
        error "Field size p must be at least parameter OrderBound";
    end if;


    t := Ceiling(Log(2, p));
    s := Floor((t - 1) / 160);
    v := t - 160 * s;
    g := Ceiling(Log(2, OrderBound));

    while true do
        // Choose a random bit string of size >= 160
        z := RandomBits(g);
        seedE := IntegerToString(z, 16); // Convert to hexadecimal
        H := HexStringToBinarySequence(SHA1(seedE));

        c0 := TakeLast(H, v);

        W0 := c0;
        W0[1] := 0; // Set the first bit to 0
        W := [W0];

        for i in [1..s] do
            si := (z + i) mod OrderBound;
            Wi := HexStringToBinarySequence(SHA1(IntegerToString(si)));
            Append(~W, Wi);
        end for;

        // Concatenate the elements of W
        W := &cat W;
        r := SequenceToInteger(W, 2);

        if r ne 0 and ((4*r + 27) mod p) ne 0 then
            return EllipticCurve([F | r, r]);
        end if;
    end while;
end function;

/* ELLIPTIC CURVE PARAMETER GENERATION FOR CRYPTOGRAPHIC APPLICATIONS
* @param b: Bit size of the random prime p where the elliptic curve is going
*           to be defined.
* @output E, G, n, h : Random elliptic curve over Fp, base point G,
*                        order of the base point n and cofactor h
*/
function CryptoCurve(b)
    if b le 160 then
        error "Bit size must be at bigger than 160";
    end if;

    // Choose a prime p
    p := PrimeOfBitSize(b);
    F := GF(p);
    OrderBound := 2^160;

    cond := false;
    repeat 
        E := RandomECFp(F, OrderBound);
        N := #E;

        factors := [ x[1] : x in  Factorization(N) ];

        if exists(n) {x : x in factors | x gt 2^160 and x gt 4*Sqrt(p)} then
            valid := true;

            for k in [1..20] do
                if Modexp(p,k,n) eq 1 then
                    valid := false;
                    break;
                end if;
            end for;

            if valid and (n ne p) then
                repeat
                    G1 := Random(E); // Select a base point G on the curve
                    h := (N div n); // cofactor
                    G := h * G1;
                until G ne E!0;
                cond := true;
            end if;

        end if;
    until cond;

    // Return the elliptic curve, the base point, the order of the base point and the cofactor
    return E, G, n, h;
end function;
