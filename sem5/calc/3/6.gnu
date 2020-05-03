#!/usr/bin/gnuplot
set terminal png size 600,400
set output 'p6.png'
#set nokey
set zeroaxis lw 2.5
set yzeroaxis lw 2.5
set grid

f(x) = exp(1 - x) - 1
g(x) = x * exp(-x)
set xrange [-4:8]
set yrange [-4:4]
plot f(x), g(x)

