#!/usr/bin/julia
# Michal Gancarczyk

# tp - typ zmiennych
function geteps(tp)
	x::tp = 1 # iterator pętli
	while tp(1) + x / 2 > tp(1)
		x /= 2.0
	end
	return x
end

# tp - typ zmiennych
function geteta(tp)
	x::tp = 1 # iterator pętli
	while x / 2 > 0
		x /= 2
	end
	return x
end

# tp - typ zmiennych
function getmax(tp)
    # x - iterator pętli wyznaczającej maksymalną
    # wielokrotność 2, którą można zapisać w zmiennej typu tp
    x::tp = 1 
    while !isinf(x * 2)
        x *= 2
    end

    # s - iterator pętli wyznaczającej maksymalną
    # liczbę, którą można zapisać w zmiennej typu tp
    s::tp = 0
    while x > 0 && !isinf(s + x)
        s += x
        x /= 2
    end
    return s
end

println("eps(Float16)            = ", eps(Float16))
println("geteps(Float16)         = ", geteps(Float16))
println("eps(Float32)            = ", eps(Float32))
println("geteps(Float32)         = ", geteps(Float32))
println("eps(Float64)            = ", eps(Float64))
println("geteps(Float64)         = ", geteps(Float64))
println()
println("nextfloat(Float16(0.0)) = ", nextfloat(Float16(0.0)))
println("geteta(Float16)         = ", geteta(Float16))
println("extfloat(Float32(0.0))  = ", nextfloat(Float32(0.0)))
println("geteta(Float32)         = ", geteta(Float32))
println("nextfloat(Float64(0.0)) = ", nextfloat(Float64(0.0)))
println("geteta(Float64)         = ", geteta(Float64))
println()
println("floatmax(Float16)       = ", floatmax(Float16))
println("getmax(Float16)         = ", getmax(Float16))
println("floatmax(Float32)       = ", floatmax(Float32))
println("getmax(Float32)         = ", getmax(Float32))
println("floatmax(Float64)       = ", floatmax(Float64))
println("getmax(Float64)         = ", getmax(Float64))
