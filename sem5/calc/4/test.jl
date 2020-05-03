#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule
using  Plots

#println(ilorazyRoznicowe([1., 2., 3., 4., 10.], [0., 2., 4., -2., 4.20]))

x = [-1., 0., 1., 2.]
y = [2., 1., 2., -7.]
println(ilorazyRoznicowe(x, y))
@assert ilorazyRoznicowe(x, y) == [2., -1., 1., -2.]
println(warNewton(x, y, 1.))
@assert warNewton(x, y, 1.) == 8.
println(naturalna(x, y))
@assert naturalna(x, y) == [3., 10., 2., -7.]
savefig(rysujNnfx(x -> x ^ 2, -5., 5., 2), "test_0.png")

f(x) = x + 2
g(x) = x^2 - 2 * x + 7
savefig(rysujNnfx(f, -5., 5., 2), "test_1.png")
savefig(rysujNnfx(f, -5., 5., 20), "test_2.png")
savefig(rysujNnfx(g, -30., 30., 3), "test_3.png")
savefig(rysujNnfx(g, -30., 30., 20), "test_4.png")
