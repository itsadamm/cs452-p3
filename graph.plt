set autoscale
unset log
unset label
set title "Time to sort vs number of threads"
set xlabel "Time to sort (milliseconds)"
set ylabel "Number of Threads"
set xrange [0:14000]           # Adjusted X-axis range to match the sample
set yrange [0:35]               # Adjusted Y-axis range to match the sample
set xtics 2000                  # X-axis ticks for every 2000 milliseconds
set ytics 5                     # Y-axis ticks for every 5 threads
set style data linespoints
set term png
set output filename
plot "data.dat" using 1:2 title "time to sort" with linespoints lt rgb "purple" lw 2 pt 7
