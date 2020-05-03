#!/usr/bin/julia
# Michał Gancarczyk

export msiecznych

# Wyznaczenie miejsca zerowego funkcji metodą stycznych
# Dane:
#  f              - funkcja f(x)
#  x0, x1         - przybliżenia początkowe
#  delta, epsilon - dokładności obliczeń
#  maxit          - maksymalna dopuszczalna liczba iteracji
# Wynik: (r, v, it, err) - czwórka, gdzie
#  r   - przybliżenie pierwiastka równania f(x) = 0
#  v   - wartośćf(r)
#  it  - liczba wykonanych iteracji
#  err - sygnalizacja błędu:
#   0 - metoda zbieżna
#   1 - nie osiągnięto wymaganej dokładności w maxit iteracji
function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    f0 = f(x0)
    f1 = f(x1)
    it = 0
    while (abs(x0 - x1) > epsilon)
        if it == maxit
            return 0, 0, 0, 1
        end

        if abs(f0) > abs(f1)
            x0, x1 = x1, x0
            f0, f1 = f1, f0
        end
        
        c = x0 - f0 * ((x0 - x1) / (f0 - f1))
        fc = f(c)
        x1 = x0
        f1 = f0
        x0 = c
        f0 = fc
        it += 1
        if abs(x0 - x1) < delta || abs(fc) < epsilon
            return c, fc, it, 0
        end
    end
    return 0, 0, 0, 1
end

#println(msiecznych(x -> x^2 - 2, -3., 0., 1e-5, 1e-5, 64))
