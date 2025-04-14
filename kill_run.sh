#!/bin/bash

# If necessary, use this to cleanup dangling processes from a benchmark run
pkill -f timeout && echo "All killed"


#kill -- -$(ps -o pgid= $(pgrep -f "run_benchmark.sh") | grep -o [0-9]*)
