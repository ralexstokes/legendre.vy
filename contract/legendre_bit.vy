LOOP_ROUNDS: constant(uint256) = 2**32

@private
@constant
def legendre_bit(input_a: uint256, q: uint256) -> uint256:
    a: uint256 = input_a
    if a >= q:
        a = a % q
    if a == 1:
        return 1

    assert(q > a and q % 2 == 1)

    t: bool = True
    n: uint256 = q
    r: uint256
    tmp_a: uint256
    for _ in range(LOOP_ROUNDS):
        if a == 0:
            break
        else:
            for _1 in range(LOOP_ROUNDS):
                if a % 2 != 0:
                    break
                else:
                    a = a / 2
                    r = n % 8
                    if r == 3 or r == 5:
                        t = not t
            tmp_a = a
            a = n
            n = tmp_a

            if a % 4 == 3 and n % 4 == 3:
                t = not t
            a %= n

    if n == 1:
        if t:
            return 1
        else:
            return 0
    else:
        return 1


@private
@constant
def legendre_bit_expmod(input_a: uint256, q: uint256) -> uint256:
    a: uint256 = input_a
    if a >= q:
        a = a % q
    if a == 0:
        return 1

    assert(q > a and q % 2 == 1)

    e: uint256 = (q - 1) / 2
    x: uint256 = a
    c: uint256 = 1

    for i in range(256):
        if e == 0:
            break
        if e % 2 == 1:
            c = uint256_mulmod(c, x, q)
        x = uint256_mulmod(x, x, q)
        e /= 2
    
    if c == q - 1:
        return 0
    return 1


@private
def legendre_bit_rawcall_expmod(input_a: uint256, q: uint256) -> uint256:
    a: uint256 = input_a
    if a >= q:
        a = a % q
    if a == 0:
        return 1

    assert(q > a and q % 2 == 1)

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

@public
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
