/* 
    This file contains the function to generate and manipulate prime numbers

    Author: Sergio Domínguez Cabrera
*/

load "constants.m";

/*
    Generate a prime number with a given length in bits
    @param nbits: length of the prime number in bits
    @output: prime number
*/
function GeneratePrime(nbits)
    // Generate a random number of nbits bits
    p := Random(2^(nbits-1) + 1, 2^nbits - 1);

    // If the number is even, we make it odd
    p := BitwiseOr(p, 1);

    while not IsPrime(p) do
        // Generate a random number of nbits bits
        p := Random(2^(nbits-1) + 1, 2^nbits - 1);

        // If the number is even, we make it odd
        p := BitwiseOr(p, 1);
    end while;

    return p;
end function;

/* Generate a prime number with a given security level
 * @param t: The security level in bits (80, 112, 128, 192, 256)
 * @output: prime number
 */
function GenerateSecurityLevelPrime(t)
    // Check if the security level is valid
    if t notin SecurityLevel then
        return "Invalid security level";
    end if;

    // Generate a prime number p
    if (t gt 80) and (t lt 256) then
        p := GeneratePrime(2*t);
    elif t eq 80 then
        p := GeneratePrime(192);
    else
        p := GeneratePrime(521);
    end if;

    return p;
end function;


