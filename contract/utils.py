import os

DIR = os.path.dirname(__file__)


def get_legendre_bit_contract_code():
    file_path = os.path.join(DIR, './legendre_bit.vy')
    return open(file_path).read()
