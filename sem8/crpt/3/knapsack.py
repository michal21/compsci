#!/usr/bin/env python3

from copy import copy
from random import randbytes
from bitarray import bitarray
from gmpy2 import *
from fpylll import *

BLKSZ = 20

def genrand(s, base):
    return mpz_random(s, base) + base + 1

def keygen():
    s = random_state(int.from_bytes(randbytes(8), 'big'))
    n = 2 ** 80
    q = genrand(s, n)

    w = []
    for i in range(BLKSZ):
        n = genrand(s, q)
        w.append(n)
        q += n

    while True:
        r = mpz_random(s, q - 2) + 1
        if gcd(q, r) == 1:
            break

    b = []
    for i in range(BLKSZ):
        b.append(mod(w[i] * r, q))

    return(q, r, w, b)

def encrypt(s, b):
    a=bitarray()
    a.frombytes(s)
    if len(a) % BLKSZ != 0:
        raise Exception('len(a) % BLKSZ != 0')

    r = []
    for i in range(len(a) // BLKSZ):
        r.append(0)
        for j in range(BLKSZ):
            if a[i * BLKSZ + j] == 1:
                r[-1] += b[j]

    return r

def decrypt(s, q, r, w):
    a = bitarray(len(s) * BLKSZ)
    m = invert(r, q)

    for i in range(len(a) // BLKSZ):
        n = mod(s[i] * m, q)
        for j in range(BLKSZ - 1, -1, -1):
            if w[j] <= n:
                a[i * BLKSZ + j]=1
                n -= w[j]
            else:
                a[i * BLKSZ + j]=0

    return a.tobytes()

def attack(e, b):
    ret = bitarray()
    lb = len(b)
    a = IntegerMatrix(lb + 1, lb + 1)

    for i in range(lb):
        a[i, i] = 1
        a[i, lb] = int(b[i])

    for c in e:
        a[lb, lb] = int(-c)
        r = LLL.reduction(copy(a))
        for y in range(lb + 1):
            rr = r[y]
            if len(list(filter(lambda x: x not in (0, 1), rr))) == 0:
                break
        else:
            raise Exception('Cannot decrypt')
        ret.extend(list(rr)[:-1])

    return ret.tobytes()

q, r, w, b = keygen()
e = encrypt(b'testtest!!1234567890', b)
p = decrypt(e, q, r, w)

print(f'q = {q}\n')
print(f'r = {r}\n')
print(f'w = {w}\n')
print(f'b = {b}\n')
print(f'e = {e}\n')
print(f'p = {p}\n')

a = attack(e, b)

print(f'a = {a}\n')

