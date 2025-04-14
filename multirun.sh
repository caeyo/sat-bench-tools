#!/bin/bash

for i in $(seq 0.91 0.01 0.94); do 
    ./run_benchmark.sh 192 benchmarks/main_2017-2024 filters/main_500_2025-04-07 "minisat-simp-lsids-decay_$i" "../minisat-mab/build/minisat -no-luby -rinc=1.5 -var-decay=$i" 5000 ;
    echo "decay_$i done at $(date)";
done

for i in $(seq 0.81 0.01 0.83); do 
    ./run_benchmark.sh 192 benchmarks/main_2017-2024 filters/main_500_2025-04-07 "minisat-simp-lsids-decay_$i" "../minisat-mab/build/minisat -no-luby -rinc=1.5 -var-decay=$i" 5000 ;
    echo "decay_$i done at $(date)";
done
