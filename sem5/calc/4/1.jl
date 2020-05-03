#!/usr/bin/julia
# Michal Gancarczyk

export ilorazyRoznicowe

# Obliczanie ilorazów różnicowych
# Dane:
#  x - wektor długości n + 1 zawierający węzły x0, ..., xn
#   x[1] = x0, ..., x[n+1] = xn
#  f - wektor długości n + 1 zawierający wartości interpolowanej funkcji w węzłach f(x0), ..., f(xn)
# Wynik:
#  wektor fx długości n + 1 zawierający obliczone ilorazy różnicowe
#   fx[1] = f[x0], fx[2] = f[x0, x1], ..., fx[n] = f[x0, ..., xn−1], fx[n+1] = f[x0, ..., xn]
function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    n = length(x) # długość wektorów
    fx = copy(f)  # wektor wynikowy

    for i = 2 : n
        for j = n : -1 : i
            fx[j] = (fx[j] - fx[j - 1]) / (x[j] - x[j - (i - 1)])
        end
    end
    
    return fx    
end
