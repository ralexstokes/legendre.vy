from hashlib import (
    sha256,
)
from random import (
    randint,
)

import pytest

import eth_utils

from .utils import (
    jacobi_bit_multi
)
from .challenges import challenges

def jacobi_bit_mpz(a, n):
    return 1 if jacobi(a, n) >= 0 else 0

def jacobi_bit_multi(a, n, m):
    r = 0
    for i in range(m):
        r *= 2
        r += jacobi_bit_mpz(a + i, n)
    return r

@pytest.mark.parametrize(
    'challenge_no,challenge', challenges.items()
)
def test_check_challenge(legendre_bit_contract,
                      w3,
                      challenge_no,
                      challenge):
    print(challenge_no, challenge)
    call = legendre_bit_contract.functions.challenges__redeemed(challenge_no)
    redeemed = call.call()
    assert not redeemed
    call = legendre_bit_contract.functions.challenges__bounty(challenge_no)
    bounty = call.call()
    assert bounty == challenge["bounty"]
    call = legendre_bit_contract.functions.challenges__check_length(challenge_no)
    check_length = call.call()
    assert check_length == challenge["check_length"]    
    call = legendre_bit_contract.functions.challenges__check_value(challenge_no)
    check_value = call.call()
    assert check_value == challenge["check_value"]
    call = legendre_bit_contract.functions.challenges__prime(challenge_no)
    prime = call.call()
    assert prime == challenge["prime"]
