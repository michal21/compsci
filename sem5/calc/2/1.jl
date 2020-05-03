#!/usr/bin/julia
# Michal Gancarczyk

# tp - typ zmiennych
function calc(tp)
	# wektory x, y
    x = [2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995]
    y = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

    s::tp = 0 # suma iloczynów (dla wyniku podpunktów A i B)
    for i = 1 : length(x)
        s += tp(x[i]) * tp(y[i])
    end
    println("a = $s")

    s = 0
    for i = length(x) : -1 : 1
        s += tp(x[i]) * tp(y[i])
    end
    println("b = $s")

    z = Vector{tp}(undef, length(x))
    for i = 1 : length(x)
        z[i] = tp(x[i]) * tp(y[i])
    end

    sp::tp = 0 # nieujemna suma iloczynów (dla częściowego wyniku podpunktów C i D)
    sn::tp = 0 # ujemna suma iloczynów (dla częściowego wyniku podpunktów C i D)
    for i in sort(z[z .> 0], rev=true)
        sp += tp(i)
    end
    for i in sort(z[z .< 0], rev=false)
        sn += tp(i)
    end
    println("c = $(sp + sn)")

    sp = 0
    sn = 0
    for i in sort(z[z .> 0], rev=false)
        sp += tp(i)
    end
    for i in sort(z[z .< 0], rev=true)
        sn += tp(i)
    end
    println("d = $(sp + sn)")
end

println("Float64:")
calc(Float64)
println("Float32:")
calc(Float32)
