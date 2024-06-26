/* 
    ELLIPTIC CURVE GENERATION (NAIVE IMPLEMENTATION)

    Author: Sergio Domínguez Cabrera
*/

// Imports
load "utils.m";

/* Generate elliptic curve over Fp with a given bit size (NAIVE IMPLEMENTATION)
 * @param t: bit size of the prime p
*  @output: Elliptic curve over Fp
*/
function EllipticCurveBits(t: RngIntElt)
    // Generate prime p of size t
    p := PrimeOfBitSize(t);

    // We are going to work with Fp
    F := FiniteField(p);

    // Select random a, b from Fp and check that 4a^3 + 27b^2 != 0
    repeat
        a := Random(F);
        b := Random(F);
    until (4*a^3 + 27*b^2) ne 0;

    // Create the elliptic curve E: y^2 = x^3 + ax + b
    return EllipticCurve([F | a, b]);
end function;

/*
* Generate Elliptic Curve domain parameters (NAIVE)
*/
function NaiveECParams(t: RngIntElt)
    repeat
        E := EllipticCurveBits(t);

        t := 0;
        repeat
            G := Random(E);
            t +:= 1;
            cond := IsOdd(Order(G));
        until cond or t gt 40;
    until cond; // We want a prime order to be able to sign

    return E, G, Order(G);
end function;

/* Generate elliptic curve over Fp with a given bit size (SMOOTH)
*/
function SmoothECParams(t, Bbits)

    // Generate random point G such that its order is 10^5 smooth
    repeat
        E := EllipticCurveBits(t);
        for i in [1..Bbits] do
            G := Random(E);
            if IsBSmooth(Order(G), 2^Bbits) then
                break;
            end if;
        end for;
    until IsBSmooth(Order(G), 2^Bbits);

    return E, G, Order(G);
end function;


