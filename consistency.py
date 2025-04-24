import csv
import sys
from collections import defaultdict


def read_csv_data(file_path):
    with open(file_path, 'r') as f:
        reader = csv.reader(f)
        rows = list(reader)
        
        try:
            header_row = rows[1]
            result_col = header_row.index('result')
        except (IndexError, ValueError) as e:
            sys.exit(f"Error in {file_path}: {str(e)}")

        data = {}
        for row in rows[2:]:
            if not row:
                continue
            try:
                benchmark = row[0].strip()
                result = row[result_col].strip().upper()
                if result not in {'INDET', 'SAT', 'UNSAT'}:
                    raise ValueError(f"Invalid result value '{result}'")
                data[benchmark] = result
            except (IndexError, ValueError) as e:
                sys.exit(f"Error in {file_path}: {str(e)}")
        return data


def main():
    if len(sys.argv) < 2:
        sys.exit("Usage: python check_consistency.py file1.csv file2.csv ...")

    aggregated = defaultdict(list)
    for file_path in sys.argv[1:]:
        file_data = read_csv_data(file_path)
        for bench, result in file_data.items():
            aggregated[bench].append(result)

    inconsistent = []
    for bench, results in aggregated.items():
        non_indet = [r for r in results if r != 'INDET']
        if len(non_indet) > 1 and len(set(non_indet)) > 1:
            inconsistent.append(bench)

    if inconsistent:
        print("Inconsistent benchmarks:")
        for bench in sorted(inconsistent):
            print(f"- {bench}")
    else:
        print("All benchmarks are consistent")


if __name__ == "__main__":
    main()

