#!/usr/bin/julia
# Michal Gancarczyk

export naturalna

# Dane:
#  x  - wektor długości n + 1 zawierający węzły x0, ..., xn
#   x[1] = x0, ..., x[n+1] = xn
#  fx - wektor długości n + 1 zawierający ilorazy różnicowe
#   fx[1] = f[x0],
#   fx[2] = f[x0, x1], ..., fx[n] = f[x0, ..., xn−1], fx[n+1] = f[x0, ..., xn]
# Wynik:
#  wektor "a" długości n + 1 zawierający obliczone współczynniki postaci naturalnej
#   a[1] = a0, a[2] = a1, ..., a[n] = an−1, a[n+1] = an
function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(x)                 # długość Wektorów
    a = Vector{Float64}(undef, n) # wektor Wynikowy

    a[n] = fx[n]
    for i = n - 1 : -1 : 1
        a[i] = fx[i]
        for j = i : n - 1
            a[j] = a[j] - x[i] * a[j + 1]
        end
    end

    return a
end
