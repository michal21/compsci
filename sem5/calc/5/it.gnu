#!/usr/bin/gnuplot
set terminal png size 1200,800
set output 'it.png'
#set nokey
set zeroaxis lw 2.5
set yzeroaxis lw 2.5
set grid

set xlabel "Rozmiar macierzy"
set ylabel "Liczba operacji"

#set xrange [-4:8]
#set yrange [-4:4]
plot "it.txt" u 1:2 w lp t "Eliminacja Gaussa", \
     "it.txt" u 1:3 w lp t "Eliminacja Gaussa z wyborem", \
     "it.txt" u 1:4 w lp t "Rozkład LU", \
     "it.txt" u 1:5 w lp t "Rozkład LU z wyborem"

