#!/usr/bin/julia
# Michal Gancarczyk

# n  - ilość iteracji
# r  - wartość stałej r
# p0 - początkowa wartość funkcji (dla n = 0)
# t  - typ danych
function p(n, r, p0, t)
    if (n == 0)
        return t(p0)
    else
        pn1::t = p(n-1, r, p0, t)
        return pn1 + t(r) * pn1 * t(1 - pn1)
    end
end

# Zmodyfikowana wersja poprzedniej funkcji
function mp(n, r, p0, t)
    if (n == 0)
        return t(p0)
    else
        pn1::t = mp(n-1, r, p0, t)
        res::t = pn1 + t(r) * pn1 * t(1 - pn1)
        return (n == 10) ? t(trunc(res * 1000) / 1000) : res
    end
end


#println("p, Float32: ", p(40, 3, 0.01, Float32))
#println("mp, Float32: ", mp(40, 3, 0.01, Float32))

#println("p, Float64: ", p(40, 3, 0.01, Float32))
#println("p, Float64: ", p(40, 3, 0.01, Float64))

for i in 1:40
	#println("$i & ", p(i, 3, .01, Float32), " & ", mp(i, 3, .01, Float32), " \\\\\\hline")
	println("$i & ", p(i, 3, .01, Float32), " & ", p(i, 3, .01, Float64), " \\\\\\hline")
end

#for i in 1:40
#	println("$i ", p(i, 3, .01, Float64))
#end

