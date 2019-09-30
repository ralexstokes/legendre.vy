from hashlib import (
    sha256,
)
from random import (
    randint,
)
from .utils import (
    jacobi_bit_multi
)

import pytest

import eth_utils

PRIMES = [
18446744073709551629,
1208925819614629174706189,
1267650600228229401496703205653,
356811923176489970264571492362373784095686747,
#57896044618658097711785492504343953926634992332820282019728792003956564820063
]

VALUES = [randint(0, 2**256 - 1) for i in range(10)]

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
    call = legendre_bit_contract.functions.legendre_bit_multi_test(value, prime, 100)
    print(call.estimateGas())
    result = call.call()
    assert result == jacobi_bit_multi(value, prime, 100)
