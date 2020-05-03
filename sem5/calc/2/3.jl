#!/usr/bin/julia
# Michal Gancarczyk

using LinearAlgebra

include("hilb.jl")
include("matcond.jl")

# A - macierz
# n - stopień macierzy
function solve(A, n)
    x = ones(Float64, n)
    b = A * x
    gx = A \ b
    ix = inv(A) * b
    return [abs(norm(x - gx) / norm(x)), abs(norm(x - ix) / norm(x))]
end

println("*** Hilb ***")
for n = 1:20
    A = hilb(n)
    sol = solve(A, n)
    println("n: $n, rank: $(rank(A)), cond: $(cond(A)), e1: $(sol[1]), e2: $(sol[2])")
    #println("$n & $(rank(A)) & $(cond(A)) & $(sol[1]) & $(sol[2]) \\\\\\hline")
end

println("\n*** Rand ***")
for n = [5, 10, 20], c = [1.0, 10.0, 10.0^3, 10.0^7, 10.0^12, 10.0^16]
    A = matcond(n, c)
    sol = solve(A, n)
    println("n: $n, c: $c, rank: $(rank(A)), cond: $(cond(A)), e1: $(sol[1]), e2: $(sol[2])")
    #println("$n & $(rank(A)) & $(cond(A)) & $(sol[1]) & $(sol[2]) \\\\\\hline")
end
