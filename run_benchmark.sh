#!/bin/bash

if [ "$#" -ne 8 ]; then
    echo "Usage: $0 <num_cores> <benchmark_dir> <benchmark_filter> <benchmark_tag> <csv_header_file> <result_dir> <run_cmd> <timeout>"
    exit 1
fi

N=$1
DIR=$2
LIST=$3
TAG=$4
CSVHEADER=$5
OUTDIR=$6
CMD=$7
TIMEOUT=$8

# Setup interrupt handling
intfn() {
    pkill -f timeout
    rm -rf "$tmp_dir"
    echo "Benchmark run for ${TAG} cancelled"
    exit
}
trap "intfn" INT

tmp_dir=".tmp_$(date '+%Y-%m-%d-%H-%M-%S')"
mkdir -p "$tmp_dir"

# Create file lists
files=($(ls $DIR | grep -f $LIST | shuf))
total_files=${#files[@]}
files_per_list=$((total_files / N))
remainder=$((total_files % N))
for ((i=0; i<N; i++)); do
     start=$((i * files_per_list + (i < remainder ? i : remainder)))
     end=$((start + files_per_list + (i < remainder ? 1 : 0)))
    printf "%s\n" "${files[@]:start:end-start}" > "${tmp_dir}/file_list_$i.txt"
done

# Create results directory
RESULTS_DIR="${tmp_dir}/results"
mkdir -p "$RESULTS_DIR"

# Allocate processes using taskset
for ((i=0; i<N; i++)); do
    file_list=$(cat "${tmp_dir}/file_list_$i.txt" | tr '\n' ',' | sed 's/,$//')
    taskset -c $i bash -c "
        for file in ${file_list//,/ }; do
            timeout $TIMEOUT $CMD -csv \"$DIR/\$file\" \"$RESULTS_DIR/\${file%.cnf.gz}\" &> /dev/null 
        done
    " &
done
# Wait for all background processes to finish
wait

# Output the temporary results to consolidated csv file
mkdir -p "${OUTDIR}"
out_file="${OUTDIR}/${TAG}|$(basename $LIST)|$(date '+%Y-%m-%d-%H-%M-%S').csv"
touch ${out_file}
# Save command
echo "${CMD}" >> ${out_file}
# CSV header
cat ${CSVHEADER} >> ${out_file}
# Results
for file in "${RESULTS_DIR}"/*; do
    fname=$(basename $file)
    echo -n "$fname" >> ${out_file}
    echo -n "," >> ${out_file}
    cat $file >> ${out_file}
    echo >> ${out_file}
done

# cleanup
rm -rf "$tmp_dir"

echo "Benchmark run for ${TAG} completed at $(date)"
