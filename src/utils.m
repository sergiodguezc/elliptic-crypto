/*
    HELPER FUNCTIONS FOR THE PROJECT.
 
    Author: Sergio Domínguez Cabrera
*/

/*
    Generate a prime number with a given length in bits
    @param nbits: length of the prime number in bits
    @output: prime number
*/
function PrimeOfBitSize(nbits)
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

// Convert a string repreenting a number in hexadecimal to an integer
function HexStringToBinarySequence(s)
    // s is a hexadecimal string
    int_s := StringToInteger(s, 16);
    return IntegerToSequence(int_s, 2);
end function;

// Takes the first n elements of a sequence
function Take(l, n)
    return [l[i] : i in [1..n]];
end function;

// Takes the last n elements of a sequence
function TakeLast(l, n)
    return [l[i] : i in [#l - n + 1..#l]];
end function;


// Solve a system of congruences
function SolveCongruences(x, p)
    r := #x - 1;  // The number of congruences - 1
    M := 1;       // The product of all p_i
    for i in [0..r] do
        M *:= p[i+1];
    end for;

    // Compute the solution x
    x_sol := 0;
    for i in [0..r] do
        M_i := M div p[i+1];
        M_i_inv := Modinv(M_i, p[i+1]); // Inverse of M_i modulo p[i+1]
        x_sol +:= x[i+1] * M_i * M_i_inv;
    end for;

    return x_sol mod M;
end function;

// Check if a number is B-smooth
// @param n: number to check
// @param B: smoothness bound
// @output: true if n is B-smooth, false otherwise
function IsBSmooth(n , B)
    return not exists(n) {f : f in Factorization(n) | f[1] gt B};
end function;
