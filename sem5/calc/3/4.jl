#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule

p = .5e-5
f(x) = sin(x) - (.5 * x)^2

println(mbisekcji(f, 1.5, 2., p, p))
println(mstycznych(f, x->cos(x) - (x / 2), 1.5, p, p, 64))
println(msiecznych(f, 1., 2., p, p, 64))

