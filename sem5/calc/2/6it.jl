#!/usr/bin/julia
# Michal Gancarczyk

# c  - stała c
# x0 - wartość dla x(0)
function it(c, x0)
    xs = [x0]
    function x(n, c, x0)
        if (n == 0)
            return x0
        else
            res = x(n - 1, c, x0) ^ 2 + c
            push!(xs, res)
            return res
        end
    end
    x(40, c, x0)

    println("$x0 0")
    for i = 1 : length(xs) - 1
        println("$(xs[i]) $(xs[i+1])")
        println("$(xs[i+1]) $(xs[i+1])")
    end
end

println("#!/bin/sh")

println("gnuplot -e c=-2 6.gnu > p6_0.png <<EOF")
it(-2, 1)
println("EOF")

println("gnuplot -e c=-2 6.gnu > p6_1.png <<EOF")
it(-2, 2)
println("EOF")

println("gnuplot -e c=-2 6.gnu > p6_2.png <<EOF")
it(-2, 1.99999999999999)
println("EOF")

println("gnuplot -e c=-1 6.gnu > p6_3.png <<EOF")
it(-1, 1)
println("EOF")

println("gnuplot -e c=-1 6.gnu > p6_4.png <<EOF")
it(-1, -1)
println("EOF")

println("gnuplot -e c=-1 6.gnu > p6_5.png <<EOF")
it(-1, .75)
println("EOF")

println("gnuplot -e c=-1 6.gnu > p6_6.png <<EOF")
it(-1, .25)
println("EOF")
