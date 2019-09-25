LOOP_ROUNDS: constant(uint256) = 2**32

@public
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
