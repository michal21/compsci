#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule

e = Base.MathConstants.e
p = 1e-4

f(x) = e ^ x - 3. * x

println("x0: ", mbisekcji(f, 0., 1., p, p))
println("x1: ", mbisekcji(f, 1., 2., p, p))

