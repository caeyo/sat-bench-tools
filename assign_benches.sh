#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <num_cores> <benchmark_dir> <benchmark_filter> <output_dir>"
    exit 1
fi

N=$1
BENCHDIR=$2
FILTER=$3
OUTDIR=$4

mkdir -p "$OUTDIR"

files=($(ls $BENCHDIR | grep -f $FILTER | shuf))
total_files=${#files[@]}
files_per_list=$((total_files / N))
remainder=$((total_files % N))
for ((i=0; i<N; i++)); do
    start=$((i * files_per_list + (i < remainder ? i : remainder)))
    end=$((start + files_per_list + (i < remainder ? 1 : 0)))
    echo -n "${files[start]}" > $OUTDIR/$i.txt
    printf " %s" "${files[@]:start+1:end-start}" >> "$OUTDIR/$i.txt"
done
