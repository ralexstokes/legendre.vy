struct Challenge:
    check_value: uint256
    check_length: uint256
    prime: uint256
    bounty: wei_value
    redeemed: bool

LOOP_ROUNDS: constant(uint256) = 2**32
HOUR: constant(timedelta) = 3600
DAY: constant(timedelta) = 24 * HOUR
YEAR: constant(timedelta) = 365 * HOUR

contract_terminates: timestamp
owner: address 

challenges: public(map(uint256, Challenge))
locks: public(map(bytes32, address))

challenges_length: uint256

@public
@payable
def __init__():
    self.owner = msg.sender
    self.contract_terminates = block.timestamp + 3 * YEAR
    # Test challenges
    self.challenges[0] = Challenge({check_value: 11000376394030634920152109547510169061,
                        check_length: 128,
                        prime: 18446744073709551629,
                        bounty: 6400000000000000000,
                        redeemed: False})
    self.challenges[1] = Challenge({check_value: 211315256989990178547101110263436988077215608,
                        check_length: 148,
                        prime: 19342813113834066795298819,
                        bounty: 8400000000000000000,
                        redeemed: False})
    self.challenges[2] = Challenge({check_value: 242829690746151433119885568607676994314595293,
                        check_length: 148,
                        prime: 1267650600228229401496703205653,
                        bounty: 10000000000000000000,
                        redeemed: False})
    self.challenges[3] = Challenge({check_value: 277818055635125894500549508635020939361127221,
                        check_length: 148,
                        prime: 356811923176489970264571492362373784095686747,
                        bounty: 14800000000000000000,
                        redeemed: False})
    self.challenges_length = 4                                                                            

# @private
# @constant
# def legendre_bit(input_a: uint256, q: uint256) -> uint256:
#     a: uint256 = input_a
#     if a >= q:
#         a = a % q
#     if a == 1:
#         return 1

#     assert(q > a and q % 2 == 1)

#     t: bool = True
#     n: uint256 = q
#     r: uint256
#     tmp_a: uint256
#     for _ in range(LOOP_ROUNDS):
#         if a == 0:
#             break
#         else:
#             for _1 in range(LOOP_ROUNDS):
#                 if a % 2 != 0:
#                     break
#                 else:
#                     a = a / 2
#                     r = n % 8
#                     if r == 3 or r == 5:
#                         t = not t
#             tmp_a = a
#             a = n
#             n = tmp_a

#             if a % 4 == 3 and n % 4 == 3:
#                 t = not t
#             a %= n

#     if n == 1:
#         if t:
#             return 1
#         else:
#             return 0
#     else:
#         return 1


# @private
# @constant
# def legendre_bit_expmod(input_a: uint256, q: uint256) -> uint256:
#     a: uint256 = input_a
#     if a >= q:
#         a = a % q
#     if a == 0:
#         return 1

#     assert(q > a and q % 2 == 1)

#     e: uint256 = (q - 1) / 2
#     x: uint256 = a
#     c: uint256 = 1

#     for i in range(256):
#         if e == 0:
#             break
#         if e % 2 == 1:
#             c = uint256_mulmod(c, x, q)
#         x = uint256_mulmod(x, x, q)
#         e /= 2
    
#     if c == q - 1:
#         return 0
#     return 1


@private
def legendre_bit_rawcall_expmod(input_a: uint256, q: uint256) -> uint256:
    a: uint256 = input_a
    if a >= q:
        a = a % q
    if a == 0:
        return 1

    assert(q % 2 == 1)
    #assert(q > a and q % 2 == 1)

    e: uint256 = (q - 1) / 2
    b: uint256 = 32

    c: uint256 = convert(raw_call(0x0000000000000000000000000000000000000005, 
    concat(convert(b, bytes32), convert(b, bytes32), convert(b, bytes32),
    convert(a, bytes32),
    convert(e, bytes32),
    convert(q, bytes32)
    ), gas=100000, outsize=32), uint256)
    
    if c == q - 1:
        return 0
    return 1

@private
def legendre_bit_multi(input_a: uint256, q: uint256, input_n: uint256) -> uint256:
    a: uint256 = input_a
    r: uint256 = 0
    n: uint256 = input_n
    for i in range(256):
        r *= 2
        r += self.legendre_bit_rawcall_expmod(a, q)
        a += 1
        n -= 1
        if n == 0:
            break
    return r


@public
def legendre_bit_multi_test(input_a: uint256, q: uint256, input_n: uint256) -> uint256:
    return self.legendre_bit_multi(input_a, q, input_n)


@public
def lock_bounty(key_hash: bytes32):
    self.locks[key_hash] = msg.sender

@public
def redeem_bounty(challenge_no: uint256, key: uint256):
    assert challenge_no < self.challenges_length
    challenge: Challenge = self.challenges[challenge_no]
    assert not self.challenges[challenge_no].redeemed

    key_hash: bytes32 = sha256(convert(key, bytes32))
    assert self.locks[key_hash] == msg.sender

    check_value: uint256 = self.legendre_bit_multi(key, self.challenges[challenge_no].prime, self.challenges[challenge_no].check_length)
    assert check_value == self.challenges[challenge_no].check_value
    self.challenges[challenge_no].redeemed = True
    send(msg.sender, challenge.bounty)


@public
def terminate_contract():
    assert msg.sender == self.owner
    assert block.timestamp >= self.contract_terminates
    selfdestruct(self.owner)