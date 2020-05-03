#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import blocksys
using  blocksys
import matrixgen
using  matrixgen
using  Printf
using  LinearAlgebra

function fbc(bytes::Int64)
    units   = ["K",  "M",  "G",  "T",  "P"]
    bin_div = [0x1p10, 0x1p20, 0x1p30, 0x1p40, 0x1p40]

    b = bytes == typemin(Int64) ? typemax(Int64) : abs(bytes)
    if b < 1000
        return @sprintf("%d B", b)
    end
    for i in 1:5
        if b < 999950
            return @sprintf("%.3f %sB", b / 1e3, units[i])
        end
        b /= 1000
    end
    return @sprintf("%.3f EB", b / 1e3)
end


function run(A, n, l, b)
    #if (n <= 5000)
	#	A1 = reverse(rotr90(Matrix(copy(A))), dims=2)
	#	std_r = A1 \ b
    #else
    #    std_r = zeros(n)
    #end

    #println("Gauss - Normal")
    A1 = copy(A); b1 = copy(b)
    gn_r = gaussel(A1, n, l, b1)

    A1 = copy(A); b1 = copy(b)
    gp_r = pgaussel(A1, n, l, b1)
    #println("  its: $iters")

    A1 = copy(A); b1 = copy(b)
    ln_r = solvebylu(A1, n, l, b1)

    A1 = copy(A); b1 = copy(b)
    lp_r = psolvebylu(A1, n, l, b1)


	#println(std_r)
	#println(gn_r)
	#println(gp_r)

	#std_rr = norm(ones(n) - std_r) / norm(std_r)
	gn_rr = norm(ones(n) - gn_r) / norm(gn_r)
	gp_rr = norm(ones(n) - gp_r) / norm(gp_r)
    ln_rr = norm(ones(n) - ln_r) / norm(ln_r)
    lp_rr = norm(ones(n) - lp_r) / norm(lp_r)
    println("gn: $gn_rr, gp: $gp_rr, ln: $ln_rr, lp: $lp_rr")
    #println(replace(replace("$n & $std_rr & $gn_rr & $gp_rr\\\\\\hline", r"(\d+.?\d*e?[-\+]?\d*)" => s"$\1$"), r"e\+?(-?\d+)" => s" \\cdot 10^{\1}"))
end

A = loadmatrix("Dane50000_1_1/A.txt")
b = calcrvec(A...)
run(A..., b)
