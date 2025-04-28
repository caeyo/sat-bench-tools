#!/bin/bash

if [ "$#" -ne 7 ]; then
    echo "Usage: $0 <benchmark_dir> <benchmark_assigns> <benchmark_tag> <csv_header_file> <result_dir> <run_cmd> <timeout>"
    exit 1
fi

DIR=$1
ASSIGNS=$2
TAG=$3
CSVHEADER=$4
OUTDIR=$5
CMD=$6
TIMEOUT=$7

# Setup interrupt handling
intfn() {
    pkill -f timeout
    rm -rf "$tmp_results"
    echo "Benchmark run for ${TAG} cancelled"
    exit
}
trap "intfn" INT

tmp_results=".tmp_$(date '+%Y-%m-%d-%H-%M-%S')"
mkdir -p "$tmp_results"

# Allocate processes using taskset
for file in $(ls "${ASSIGNS}"); do
    taskset -c ${file%.txt} bash -c "
        for bench in $(cat "${ASSIGNS}/${file}"); do
            timeout $TIMEOUT $CMD -csv \"$DIR/\$bench\" \"$tmp_results/\${bench%.cnf.gz}\" &> /dev/null 
        done
    " &
done
# Wait for all background processes to finish
wait

# Output the temporary results to consolidated csv file
mkdir -p "${OUTDIR}"
out_file="${OUTDIR}/${TAG}|$(basename $ASSIGNS)|$(date '+%Y-%m-%d-%H-%M-%S').csv"
touch ${out_file}
# Save command
echo "${CMD}" >> ${out_file}
# CSV header
cat ${CSVHEADER} >> ${out_file}
# Results
for file in "${tmp_results}"/*; do
    fname=$(basename $file)
    echo -n "$fname" >> ${out_file}
    echo -n "," >> ${out_file}
    cat $file >> ${out_file}
    echo >> ${out_file}
done

# cleanup
rm -rf "$tmp_results"

echo "Benchmark run for ${TAG} completed at $(date)"
