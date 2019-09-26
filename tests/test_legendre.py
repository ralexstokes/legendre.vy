from hashlib import (
    sha256,
)
from random import (
    randint,
)

import pytest

import eth_utils

from gmpy2 import jacobi

PRIMES = [
18446744073709551629,
1208925819614629174706189,
1267650600228229401496703205653,
356811923176489970264571492362373784095686747,
#57896044618658097711785492504343953926634992332820282019728792003956564820063
]

VALUES = [randint(0, 2**256 - 1) for i in range(10)]

def jacobi_bit_mpz(a, n):
    return 1 if jacobi(a, n) >= 0 else 0

def jacobi_bit_multi(a, n, m):
    r = 0
    for i in range(m):
        r *= 2
        r += jacobi_bit_mpz(a + i, n)
    return r


"""
@pytest.mark.parametrize(
    'value,prime,expected_result',
    [
        (v % p, p, jacobi_bit_mpz(v % p, p)) for p in PRIMES for v in VALUES
    ]
)
def test_legendre_bit(legendre_bit_contract,
                      w3,
                      value,
                      prime,
                      expected_result):
    call = legendre_bit_contract.functions.legendre_bit(value, prime)
    print(call.estimateGas())
    result = call.call()
    assert expected_result == result
"""

"""
@pytest.mark.parametrize(
    'value,prime,expected_result',
    [
        (v % p, p, jacobi_bit_mpz(v % p, p)) for p in PRIMES for v in VALUES
    ]
)
def test_legendre_bit_expmod(legendre_bit_contract,
                      w3,
                      value,
                      prime,
                      expected_result):
    call = legendre_bit_contract.functions.legendre_bit_expmod(value, prime)
    print(call.estimateGas())
    result = call.call()
    assert expected_result == result
"""

@pytest.mark.parametrize(
    'value,prime',
    [
        (v, p) for p in PRIMES for v in VALUES
    ]
)
def test_legendre_bit_multi(legendre_bit_contract,
                      w3,
                      value,
                      prime):
    call = legendre_bit_contract.functions.legendre_bit_multi(value, prime, 100)
    print(call.estimateGas())
    result = call.call()
    assert result == jacobi_bit_multi(value, prime, 100)
