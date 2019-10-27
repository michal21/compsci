#!/usr/bin/julia
# Michal Gancarczyk

# s - początek przedziału przeszukiwania
# e - koniec przedziału przeszukiwania
function printnum(s, e)
    x::Float64 = s # iterator pętli
    while x < e
        if x * (1 / x) != 1
            println("x = $x,\tx * (1 / x) = $(x * (1 / x))")
            return
        end
        x = nextfloat(x)
	end
end

printnum(1, 2)
