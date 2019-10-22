#!/usr/bin/julia
# Michal Gancarczyk

# tp - typ zmiennej, dla której wyznaczony ma być macheps
geteps(tp) = tp(3) * (tp(4) / tp(3) - tp(1)) - tp(1)

println("eps(Float16)            = ", eps(Float16))
println("geteps(Float16)         = ", geteps(Float16))
println("eps(Float32)            = ", eps(Float32))
println("geteps(Float32)         = ", geteps(Float32))
println("eps(Float64)            = ", eps(Float64))
println("geteps(Float64)         = ", geteps(Float64))
