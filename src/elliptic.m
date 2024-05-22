/* 
    Elliptic Curve Math Library
    Author: Sergio Domínguez Cabrera
*/

// Imports
load "primes.m";


/* Generate elliptic curve domain parameters over Fp
*  @param t: The security level in bits (80, 112, 128, 192, 256)
*  @output: A tuple (p, a, b, G, n, h)
*/
function GenerateEllipticCurveParameters(t)
    // Generate prime p according to the security level
    p := GenerateSecurityLevelPrime(t);

    // Select random a, b from Fp and check that 4a^3 + 27b^2 != 0
    repeat 
        a := Random(0, p-1);
        b := Random(0, p-1);
    until (4*a^3 + 27*b^2) mod p ne 0;


    return p, a, b;
end function;

