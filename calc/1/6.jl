#!/usr/bin/julia
# Michal Gancarczyk

# implementacja funkcji opisanych w poleceniu
f(x) = sqrt(x ^ 2 + 1) - 1
g(x) = x ^ 2 / (sqrt(x ^ 2 + 1) + 1)

# p - iterator pętli
for p = 1 : 20
    fp = f(8.0 ^ (-p))
    gp = g(8.0 ^ (-p))
    println("f(8^-$p) = $fp,\tg(8^-$p) = $gp")
end
