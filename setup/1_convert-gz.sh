#!/bin/bash

# use to convert all .xz files from SAT benchmark DB to gzip format (e.g. for minisat)

if [ $# -ne 1 ]; then
    echo "Need directory to convert"
    exit 1
fi

cd "$1"
for file in *.xz; do
    base="${file%.xz}"
    xz -dv "$file"
    gzip -vc "$base" > "${base}.gz"
    rm "$base"
done
