from contract.utils import (
    get_legendre_bit_contract_code,
)
from vyper import (
    compiler,
)


def test_compile_legendre_bit_contract():
    legendre_bit_contract_code = get_legendre_bit_contract_code()
    abi = compiler.mk_full_signature(legendre_bit_contract_code)
    bytecode = compiler.compile_code(legendre_bit_contract_code)['bytecode']
