from gmpy2 import jacobi

def jacobi_bit_mpz(a, n):
    return 1 if jacobi(a, n) >= 0 else 0

def jacobi_bit_multi(a, n, m):
    r = 0
    for i in range(m):
        r *= 2
        r += jacobi_bit_mpz(a + i, n)
    return r