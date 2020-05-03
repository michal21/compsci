#!/usr/bin/julia
# Michal Gancarczyk

using Plots

# wersja funkcji dla Float32
f32(x) = Float32(Float32(Float32(Base.MathConstants.e)^Float32(x)) * Float32(log(Float32(1.0) + Float32(Base.MathConstants.e)^Float32(-x))))
# wersja funkcji dla Float32
f64(x) = Base.MathConstants.e^x * log(1 + (Base.MathConstants.e^(-x)))

println("plotting")

plot(f32, -10, 40, leg=false)
savefig("p2_jl32")

plot(f64, -10, 40, leg=false)
savefig("p2_jl64")

plot(f64, -10, 1000, leg=false)
savefig("p2_jlex")
