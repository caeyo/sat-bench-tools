#!/usr/bin/env python3

import argparse
import json
import os
import shutil
import subprocess


MKPLOT_PATH = "mkplot/mkplot.py"


def csv_to_json(data_file_name, out_file, key_name):
    program_name, bench_name, _ = os.path.basename(data_file_name).split('|')
    out = {
        "preamble": {
            "program": program_name,
            "benchmark": bench_name
        },
        "stats": {}
    }
    max_comp_val = 0
    with open(data_file_name, 'r') as data_file:
        data_file.readline()
        header = data_file.readline().strip().split(',')
        key_ind = header.index(key_name)
        result_ind = header.index("result")
        for line in data_file:
            data = line.split(',')
            bench = data[0]
            solved = not data[result_ind].strip() == "INDET"
            comp_val = float(data[key_ind])
            if comp_val > max_comp_val:
                max_comp_val = comp_val
            out["stats"][bench] = { "status": solved, key_name: comp_val }
    json.dump(out, out_file)
    return max_comp_val


def create_plot(data_files, key, plot_type, out_file_name, mkplot_path, mkplot_args):
    try:
        args = ["python3", "-B", mkplot_path, f"--key={key}", "--timeout=5000", f"--plot-type={plot_type}", f"--save-to={out_file_name}"]
        if mkplot_args is not None:
            args.extend(mkplot_args)

        os.mkdir(".tmp")
        i = 1
        max_comp_val = 0
        for data_file in data_files:
            solver_file_name = f".tmp/solver{i}.json"
            args.append(solver_file_name)
            with open(solver_file_name, 'w') as solver_file:
                val = csv_to_json(data_file, solver_file, key)
                if val > max_comp_val:
                    max_comp_val = val
            i += 1
        if key != "time":
            args[3] = f"--timeout={ceil(max_comp_val)+1}"

        result = subprocess.run(args, capture_output=True)
        if result.returncode != 0:
            print(f"Error in mkplot: {result.stderr.decode()}")
            raise RuntimeError("Plot generation failed")

        print(f"Plot generated at {out_file_name}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if os.path.exists(".tmp"):
            shutil.rmtree(".tmp")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse command line arguments.')
    parser.add_argument('data_files', nargs='+', type=str)
    parser.add_argument('--out', type=str, required=True, help='Output file name')
    parser.add_argument('--mkplot', type=str, default=MKPLOT_PATH, help='mkplot path')
    parser.add_argument('--key', type=str, default="time", help='Comparison key')
    parser.add_argument('--plot', type=str, choices=['cactus', 'scatter'], default='cactus', help='Type of plot')
    parser.add_argument('--opts', nargs=argparse.REMAINDER, help='String of options to pass to mkplot')
    args = parser.parse_args()
    create_plot(args.data_files, args.key, args.plot, args.out, args.mkplot, args.opts)
