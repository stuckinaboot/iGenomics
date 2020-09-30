from sys import argv
import os

max_rt = 0
for acp in os.listdir(argv[1]):
    if ".py" in acp:
        continue
    with open(argv[1] + '/' + acp) as f:
        for i, line in enumerate(f.readlines()):
            if i == 1:
                line_comps = line.split('\t')
                max_rt = max(max_rt, float(line_comps[2]))
                break
print("{0}: {1}".format(argv[1], max_rt))
