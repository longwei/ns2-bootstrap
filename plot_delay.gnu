# !/usr/local/bin/gnuplot

set terminal gif
set output 'delay.gif'
set xlabel 'Simulation Time (s)'
set ylabel 'delay'
set title  'delay'
set grid
plot 'system_static' using 1:2 with line linetype 1 linewidth 1
