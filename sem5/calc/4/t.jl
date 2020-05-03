#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule

x = [-1., 0., 1., 2.]
y = [-1., 0., -1., 2.]

a = ilorazyRoznicowe(x, y)
println(a)
println(naturalna(x, a))
