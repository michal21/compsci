#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule
using  Plots

f(x) = abs(x)
g(x) = 1.0 / (1.0 + x^2)

savefig(rysujNnfx(f, -1.0, 1.0, 5), "p6_1.png")
savefig(rysujNnfx(f, -1.0, 1.0, 10), "p6_2.png")
savefig(rysujNnfx(f, -1.0, 1.0, 15), "p6_3.png")

savefig(rysujNnfx(g, -5.0, 5.0, 5), "p6_4.png")
savefig(rysujNnfx(g, -5.0, 5.0, 10), "p6_5.png")
savefig(rysujNnfx(g, -5.0, 5.0, 15), "p6_6.png")
