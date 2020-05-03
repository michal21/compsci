#!/usr/bin/julia
# Michał Gancarczyk

export mstycznych

# Wyznaczenie miejsca zerowego funkcji metodą stycznych
# Dane:
#  f, pf          - funkcja f(x) oraz pochodna f'(x),
#  x0             - przybliżenie początkowe,
#  delta, epsilon - dokładności obliczeń,
#  maxit          - maksymalna dopuszczalna liczba iteracji
# Wynik: (r, v, it, err) - czwórka, gdzie
#  r   - przybliżenie pierwiastka równania f(x) = 0
#  v   - wartośćf(r)
#  it  - liczba wykonanych iteracji
#  err - sygnalizacja błędu:
#   0 - metoda zbieżna
#   1 - nie osiągnięto wymaganej dokładności w maxit iteracji
#   2 - pochodna bliska zeru
function mstycznych(f, pf, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    x1 = x0 - 1
    f0 = f(x0)
    it = 0
    while abs(x1 - x0) > delta && abs(f0) > epsilon
        if it == maxit
            return 0, 0, 0, 1
        end
        f1 = pf(x0)
        if abs(f1) < epsilon
            return 0, 0, 0, 2
        end
        x1 = x0
        x0 -= (f0 / f1)
        f0 = f(x0)
        it += 1
    end
    return x0, f0, it, 0
end
