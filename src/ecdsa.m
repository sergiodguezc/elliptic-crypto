/* 
    ELLIPTIC CURVE DIGITAL SIGNATURE ALGORITHM (ECDSA)

    Author: Sergio Domínguez Cabrera
*/

/* Generate a key pair
* @param E: Elliptic curve
* @param G: Base point
* @param n: Order of G
* @output (d, G): Private key d and public key G
*/
function GenerateKeyPair(G , n)
    d := Random(1, n); // private key
    Q := d * G; // public key

    return d, Q;
end function;

/* Sign a message
* @param m: Message
* @param G: Base point
* @param n: Order of G
* @param d: Private key
*/
function Sign(m, G, n, d)
    repeat 
        repeat // Ensure that r and k are invertible modulo n
            k := Random([1..n-1]);
            kG := k * G;
            r := (Integers() ! kG[1]) mod n;
        until GCD(r, n) eq 1 and GCD(k, n) eq 1; // Always true if n is prime

        kInv := Modinv(k, n);

        // Convert the message to a hexadecimal string
        m := &cat [ IntegerToString(x, 16) : x in StringToBytes(m) ];
        e := StringToInteger(SHA1(m), 16);

        s := (kInv * (e + r * d)) mod n;

    until GCD(s, n) eq 1; // Ensure that s is invertible modulo n
                          // Always true if n is prime
    return r, s;
end function;

/* Verify a signature
* @param m: Message
* @param r: Signature component
* @param s: Signature component
* @param G: Base point
* @param n: Order of G
* @param Q: Public key
* @output: True if the signature is valid, false otherwise
*/
function Verify(m, r, s, G, n, Q)
    E := Curve(G);

    if r notin [1..n-1] or s notin [1..n-1] then
        return false;
    end if;

    m := &cat [ IntegerToString(x, 16) : x in StringToBytes(m) ];

    e := StringToInteger(SHA1(m), 16);

    w := Modinv(s, n); // When signing we ensure that s is invertible

    u1 := (e * w) mod n;
    u2 := (r * w) mod n;

    X := u1 * G + u2 * Q;

    if X eq E!0 then
        return false;
    end if;

    v := (Integers() ! X[1]) mod n;
    return v eq r;

end function;
