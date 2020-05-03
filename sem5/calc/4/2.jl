#!/usr/bin/julia
# Michal Gancarczyk

export warNewton

# Obliczanie wartości wielomianu interpolacyjnego stopnia n w postaci Newtona
# Dane:
#  x  - wektor długości n + 1 zawierający węzły x0, ..., xn
#   x[1] = x0, ..., x[n+1] = xn
#  fx - wektor długości n + 1 zawierający ilorazy różnicowe
#   fx[1] = f[x0],
#   fx[2] = f[x0, x1], ..., fx[n] = f[x0, ..., xn-1], fx[n+1] = f[x0, ..., xn]
#  t  - punkt, w którym należy obliczyć wartość wielomianu
# Wynik:
#  wartość "nt" wielomianu w punkcie t
function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x) # długość wektorów
    nt = fx[n]    # wynik
    
    for i = n - 1 : -1 : 1
        nt = nt * (t - x[i]) + fx[i]
    end
    
    return nt
end
