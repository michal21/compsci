#!/usr/bin/gnuplot
set terminal png size 600,400
set output 'p2_gp.png'
set nokey
f(x) = exp(x) * log(1 + exp(-x))
set xrange [-10:1000]
plot f(x)

