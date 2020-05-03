#!/usr/bin/gnuplot
set terminal png size 600,400
set output 'p5.png'
#set nokey
set zeroaxis lw 2.5
set yzeroaxis lw 2.5
set grid

f(x) = 3 * x
g(x) = exp(x)
set xrange [-1:2]
plot f(x), g(x)

