#!/usr/bin/env bash

function usage() {
    echo "$0 usage:" && grep " .)\ #" $0
    exit 0
}

[ $# -eq 0 ] && usage

while getopts "hs:f:" arg; do
    case $arg in
    s) # The size of the array to sort.
        size=${OPTARG}
        ;;
    f) # The plot file name
        name=${OPTARG}
        ;;
    h | *) # Display help.
        usage
        exit 0
        ;;
    esac
done

if [ -z "$name" ] || [ -z "$size" ]; then
    usage
    exit 0
fi

# Check if the compiled program exists
if [ -e ./build/lab ]; then
    # Remove old data file if it exists
    [ -e "data.dat" ] && rm -f data.dat
    
    echo "Running lab to generate data"
    echo "#Time Threads" >> data.dat
    
    for n in {1..32}; do  # Adjusted to 10 threads for the M1 Pro
        echo -ne "Running with $n thread(s) \r"
        ./build/lab "$size" "$n" >> data.dat
    done
    
    # Generate plot with gnuplot
    gnuplot -e "filename='$name.png'" graph.plt
    echo "Created plot $name.png from data.dat file"
else
    echo "Executable 'lab' is not present in the build directory. Did you compile your code?"
fi
