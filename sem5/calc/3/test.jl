#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule

e = Base.MathConstants.e
p = 1e-5
it = 512

f1(x) = x^2 + 5*x + 6
f1p(x) = 2*x + 5
f2(x) = x^3 - 4*x^2 + 6*x - 24
f2p(x) = 3*x^2 - 8*x + 6
f3(x) = e^x - 1

@assert mbisekcji(f1, -3.5, -2.5, p, p)[1] == -3.
@assert mbisekcji(f1, -2.5, -1.5, p, p)[1] == -2.
@assert mbisekcji(f1, -2.75, -2.25, p, p)[4] == 1

@assert isapprox(mstycznych(f1, f1p, -3.5, p, p, it)[1], -3.)
@assert isapprox(mstycznych(f1, f1p, -2., p, p, it)[1], -2.)
@assert isapprox(mstycznych(f2, f2p, 3.5, p, p, it)[1], 4.)

@assert isapprox(msiecznych(f2, 3.5, 4., p, p, it)[1], 4.)
@assert msiecznych(f3, 0., 2., p, p, it)[1] == 0.
@assert mbisekcji(f1, -2.75, -2.25, p, p)[4] == 1
