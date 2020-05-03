#!/usr/bin/gnuplot
set terminal png size 600,400
#set nokey

set output 'p5_pmp.png'
plot '5_p32.dat' with lines lc 'blue' title 'p', \
     '5_mp32.dat' with lines lc 'red' title 'mp'

set output 'p5_3264.png'
plot '5_p32.dat' with lines lc 'red' title 'f32', \
     '5_p64.dat' with lines lc 'blue' title 'f64'

