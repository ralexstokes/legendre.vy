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
57896044618658097711785492504343953926634992332820282019728792003956564820063
]

VALUES = [randint(0, 2**256 - 1) for i in range(10)]

def jacobi_bit_mpz(a, n):
    return 1 if jacobi(a, n) >= 0 else 0 


@pytest.mark.parametrize(
    'prime,value,expected_result',
    [
        (p, v, jacobi_bit_mpz(v, p)) for p in PRIMES for v in VALUES
    ]
)
def test_legendre_bit(legendre_bit_contract,
                      w3,
                      prime,
                      value,
                      expected_result):
    call = legendre_bit_contract.functions.legendre_bit(prime, value)
    expected_result = call.call()
    assert expected_result == result
