#!/usr/bin/gnuplot
set terminal png size 600,400
set nokey

set xzeroaxis lw 2.5
set yzeroaxis lw 2.5

set xrange [-2.5:2.5]
set yrange [-3:3]

set grid

f(x) = x
g(x) = x**2 + c

plot f(x) lc 'blue', \
     g(x) lc 'blue', \
     '/dev/stdin' using 1:2 with lines lc 'red'

