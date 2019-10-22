#!/usr/bin/julia
# Michal Gancarczyk

# przybliżenie pochodnej funkcji f
derive(f, x0, h) = (f(x0 + h) - f(x0)) / h

x0 = 1 # wartość x0 z zadania

# n - iterator pętli
for n = 0 : 54
    h = 2.0 ^ (-n)                              # wartość h
    a = cos(x0) - 3 * sin(3 * x0)               # wynik dla pochodnej
    b = derive(x -> sin(x) + cos(3 * x), x0, h) # wynik dla przybliżonej pochodnej
    r = abs(a - b)                              # błąd przybliżonej pochodnej
    println("n = $n: $r")
    #println("\$2^{-$n}\$ & $b & $r & $(1+h) \\\\\\hline")
end
