# Use this to convert the master files of URIs from benchmark site to filters for the benchmark runner

import sys

with open(sys.argv[1], "r") as fs:
    with open(sys.argv[2], "w") as fs2:
        for each in fs:
            fs2.write(each.strip()[each.rindex("/")+1:] + "\n")
