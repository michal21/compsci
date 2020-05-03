#!/usr/bin/julia
# Michal Gancarczyk

#using Plots
export rysujNnfx

# Dane:
#  f    - funkcja f(x)
#  a, b - przedział interpolacji
#  n    - stopień wielomianu interpolacyjnego
# Wynik:
#  wykres wielomianu interpolacyjnego i interpolowanej funkcji w przedziale [a, b]
function rysujNnfx(f, a::Float64, b::Float64, n::Int)
    # Wyznaczenie ilorazów różnicowych funkcji
    # x, y - wektory pomocnicze, h - odległość między węzłami
    x = Vector{Float64}(undef, n + 1)
    y = Vector{Float64}(undef, n + 1)
    h = (b - a) / n
    
    for k = 1 : n + 1
        x[k] = a + (k - 1) * h
        y[k] = f(x[k])
    end

    fx = ilorazyRoznicowe(x, y);

    # Wyznaczenie przybliżeń funkcji
    # d - gęstość punktów, xx, yy - wektory pomocnicze, h - odległość między węzłami
    d = 20
    xx = Vector{Float64}(undef, (n + 1) * d)
    yy = Vector{Float64}(undef, (n + 1) * d)
    h = (b - a) / ((n + 1) * d - 1)
    
    for k = 1 : (n + 1) * d
        xx[k] = a + (k - 1) * h
        yy[k] = warNewton(x, fx, xx[k])
    end

	#for i in 1 : 5
	#	println("$n & $i & $(f(xx[i])) & $(yy[i])\\\\\\hline")
	#end

    # Rysowanie wykresu wynikowego
 #   p = plot(f, a, b, linewidth=2.)
  #  plot!(p, xx, yy, linewidth=2.)
   # return p
end
