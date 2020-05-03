#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule
using  Plots

f(x) = exp(x)
g(x) = x^2 * sin(x)

savefig(rysujNnfx(f, 0.0, 1.0, 5), "p5_1.png")
savefig(rysujNnfx(f, 0.0, 1.0, 10), "p5_2.png")
savefig(rysujNnfx(f, 0.0, 1.0, 15), "p5_3.png")

savefig(rysujNnfx(g, -1.0, 1.0 , 5), "p5_4.png")
savefig(rysujNnfx(g, -1.0, 1.0 , 10), "p5_5.png")
savefig(rysujNnfx(g, -1.0, 1.0 , 15), "p5_6.png")
