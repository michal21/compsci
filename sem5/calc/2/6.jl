#!/usr/bin/julia
# Michal Gancarczyk

# c  - stała c
# x0 - wartość dla x(0)
function it(c, x0)
    xs = []
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
	return xs
end

res = [
    it(-2, 1),
    it(-2, 2),
    it(-2, 1.99999999999999),
    it(-1, 1),
    it(-1, -1),
    it(-1, .75),
    it(-1, .25)
]

len = length(res[1])
for i = 1 : len
    print("$i")
    for xs = res
        print(" & ", xs[i])
    end
    println(" \\\\\\hline")
end
