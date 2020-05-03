#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import blocksys
using  blocksys
import matrixgen
using  matrixgen
using  Printf

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
    #println("Gauss - Normal")
    A1 = copy(A); b1 = copy(b)
    gn_t = @elapsed gaussel(A1, n, l, b1)
    A1 = copy(A); b1 = copy(b)
    gn_m = fbc(@allocated gaussel(A1, n, l, b1))
    #println("  its: $iters")
    gn_i = iters
    
    A1 = copy(A); b1 = copy(b)
    gp_t = @elapsed pgaussel(A1, n, l, b1)
    A1 = copy(A); b1 = copy(b)
    gp_m = fbc(@allocated pgaussel(A1, n, l, b1))
    #println("  its: $iters")
    gp_i = iters
    
    #A1 = copy(A)
    #ldn_t = @elapsed ludecomp(A1, n, l)
    #A1 = copy(A)
    #ldn_m = fbc(@allocated ludecomp(A1, n, l))
    #println("  its: $iters")

    #A1 = copy(A); b1 = copy(b)
    #ludecomp(A1, n, l)
    #lsn_t = @elapsed lusolve(A1, n, l, b1)
    #A1 = copy(A); b1 = copy(b)
    #ludecomp(A1, n, l)
    #lsn_m = fbc(@allocated lusolve(A1, n, l, b1))
    #println("  its: $iters")

    A1 = copy(A); b1 = copy(b)
    lan_t = @elapsed solvebylu(A1, n, l, b1)
    A1 = copy(A); b1 = copy(b)
    lan_m = fbc(@allocated solvebylu(A1, n, l, b1))
    lan_i = iters
    #println("  its: $iters")

    #A1 = copy(A)
    #ldp_t = @elapsed pludecomp(A1, n, l)
    #A1 = copy(A)
    #ldp_m = fbc(@allocated pludecomp(A1, n, l))
    #println("  its: $iters")

    #A1 = copy(A); b1 = copy(b)
    #ord = pludecomp(A1, n, l)[2]
    #lsp_t = @elapsed plusolve(A1, n, l, b1, ord)
    #A1 = copy(A); b1 = copy(b)
    #ord = pludecomp(A1, n, l)[2]
    #lsp_m = fbc(@allocated plusolve(A1, n, l, b1, ord))
    #println("  its: $iters")

    A1 = copy(A); b1 = copy(b)
    lap_t = @elapsed psolvebylu(A1, n, l, b1)
    A1 = copy(A); b1 = copy(b)
    lap_m = fbc(@allocated psolvebylu(A1, n, l, b1))
    #println("  its: $iters")
    lap_i = iters

    println("$n $gn_i $gp_i $lan_i $lap_i")    
end

#A = loadmatrix("Dane16_1_1/A.txt")
#b = loadrvec("Dane16_1_1/b.txt")
#run(A..., b[1])

#blockmat(20, 4, 2., "/tmp/matrix.txt")
#A, n, l = loadmatrix("/tmp/matrix.txt")
#b = calcrvec(A, n, l)
#println(pgaussel(A, n, l, b))
#A, n, l = loadmatrix("/tmp/matrix.txt")
#b = calcrvec(A, n, l)
#println(psolvebylu(A, n, l, b))

#n = parse(Int64, ARGS[1])

for n = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1248, 1500, 1748, 2000, 2248, 2500, 2748, 3000, 3248, 3500, 3748, 4000, 4248, 4500, 4748, 5000]
    blockmat(n, 4, 2., "/tmp/matrix.txt")
    A = loadmatrix("/tmp/matrix.txt")
    b = calcrvec(A...)
    run(A..., b)
end
