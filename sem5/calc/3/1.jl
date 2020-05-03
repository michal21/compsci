#!/usr/bin/julia
# Michał Gancarczyk

export mbisekcji

# Wyznaczenie miejsca zerowego funkcji metodą bisekcji
# Dane:
#  f              - funkcja f(x)
#  a, b           - końce przedziału początkowego
#  delta, epsilon - dokładności obliczeń
# Wynik: (r, v, it, err) - czwórka, gdzie
#  r   - przybliżenie pierwiastka równania f(x) = 0
#  v   - wartość f(r)
#  it  - liczba wykonanych iteracji
#  err - sygnalizacja błędu:
#   0 - brak błędu
#   1 - funkcja nie zmienia znaku w przedziale [a,b]
function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
	println(f(a), f(b))
    if sign(f(a)) == sign(f(b))
        return 0, 0, 0, 1
    end
    x1 = 0
    it = 0
    while abs(a - b) > epsilon
        x1 = a + (b - a) / 2
		println(x1)
        if abs(x1) <= delta || abs(f(x1)) <= delta
            return x1, f(x1), it, 0
        elseif f(x1) * f(a) < 0
            b = x1
        else
            a = x1
        end
        it += 1
    end
end
