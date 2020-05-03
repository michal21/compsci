#!/usr/bin/julia
# Michał Gancarczyk

push!(LOAD_PATH, ".")

import MyModule
using  MyModule

e = Base.MathConstants.e
p = 1e-5
it = typemax(Int)

f1(x) = e^(1 - x) - 1
f2(x) = x * e^(-x)
f1p(x) = -e ^ (1 - x)
f2p(x) = e ^ (-x) * (1 - x)

function tbl(x, a)
	println(x, " & ", a[1], " & ", a[2], " & ", a[3], " & ", a[4], "\\\\\\hline")
end

#tbl("[0, 1.5]", mbisekcji(f1, 0., 1.5, p, p))
#tbl("[0.5, 3]", mbisekcji(f1, 0.5, 3., p, p))
tbl("[-5, 5]", mbisekcji(f1, -5., 5., p, p))
#tbl("[0, 100]", mbisekcji(f1, 0., 100., p, p))
#tbl("[-10, 2000]", mbisekcji(f1, -10., 2000., p, p))
#println()
#tbl("[-0.5, 1]", mbisekcji(f2, -.5, 1., p, p))
#tbl("[-0.25, 1.5]", mbisekcji(f2, -.25, 1.5, p, p))
#tbl("[-1, 6]", mbisekcji(f2, -1., 6., p, p))
#tbl("[-2, 100]", mbisekcji(f2, -2., 100., p, p))
#tbl("[-5, 1000]", mbisekcji(f2, -5., 1000., p, p))
#println()
#println()
#tbl("-1", mstycznych(f1, f1p, -1., p, p, it))
#tbl("0", mstycznych(f1, f1p, 0., p, p, it))
#tbl("1", mstycznych(f1, f1p, 1., p, p, it))
#tbl("2", mstycznych(f1, f1p, 2., p, p, it))
#tbl("5", mstycznych(f1, f1p, 5., p, p, it))
#tbl("7", mstycznych(f1, f1p, 7., p, p, it))
#tbl("13", mstycznych(f1, f1p, 13., p, p, it))
#println()
#tbl("-2", mstycznych(f2, f2p, -2., p, p, it))
#tbl("-1", mstycznych(f2, f2p, -1., p, p, it))
#tbl("0", mstycznych(f2, f2p, 0., p, p, it))
#tbl("0.5", mstycznych(f2, f2p, .5, p, p, it))
#tbl("1", mstycznych(f2, f2p, 1., p, p, it))
#tbl("2", mstycznych(f2, f2p, 2., p, p, it))
#tbl("100", mstycznych(f2, f2p, 100., p, p, it))
#tbl("200", mstycznych(f2, f2p, 200., p, p, it))
#println()
#println()
#tbl("-1 & 2", msiecznych(f1, -1., 2., p, p, it))
#tbl("0.5 & 3", msiecznych(f1, .5, 3., p, p, it))
#tbl("-3 & 4", msiecznych(f1, -3., 4., p, p, it))
#tbl("-2 & 6", msiecznych(f1, -2., 6., p, p, it))
#tbl("10 & 100", msiecznych(f1, 10., 100., p, p, it))
#println()
#tbl("-1 & 0.5", msiecznych(f2, -1., .5, p, p, it))
#tbl("-0.25 & 1.5", msiecznych(f2, -.25, 1.5, p, p, it))
#tbl("2 & 6", msiecznych(f2, 2., 6., p, p, it))
#tbl("10 & 20", msiecznych(f2, 10., 20., p, p, it))
#tbl("-4 & 400", msiecznych(f2, -4., 400., p, p, it))
