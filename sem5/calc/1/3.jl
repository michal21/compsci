#!/usr/bin/julia
# Michal Gancarczyk

# min   - początek przedziału
# max   - koniec przedziału
# delta - oczekiwany krok rozmieszczenia liczb
function main(min, max, delta)
    x::Float64 = min # iterator pętli - kolejne liczby wyznaczane przez nextfloat()
    i::Int = 1       # iterator pętli - kolejne liczby całkowite
    amnt::Int = 10   # maksymalna ilość wypisanych przez funkcję wyników

    while x < max && i <= amnt
        println(bitstring(min + i * delta), ", ", min + i * delta)
        if (nextfloat(x)) != (min + i * delta)
            println("No")
            exit(1)
        end
        x = nextfloat(x)
        i += 1
    end
    println()
end

main(1, 2, 2^-52)
main(1/2, 1, 2^-53)
main(2, 4, 2^-51)
