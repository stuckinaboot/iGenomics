import os
from collections import defaultdict
"""
Run from actual_data directory to get the average runtimes for each actual data test
"""

files_for_avg = 3
valid_strs = ["data{0}.acp".format(i) for i in range(1, files_for_avg + 1)]


def is_file_path_valid_str(path):
    for valid_str in valid_strs:
        try:
            idx = path.index(valid_str)
            return path[0:idx]
        except:
            pass
    return None


for ref_path in os.listdir('./'):
    try:
        runtimes = defaultdict(float)
        for file_path in os.listdir('./' + ref_path + '/igenomics_data'):
            complete_file_path = './' + ref_path + '/igenomics_data/' + file_path
            prefix_str = is_file_path_valid_str(complete_file_path)
            if prefix_str is not None:
                with open(complete_file_path) as my_file:
                    for line_num, line in enumerate(my_file.readlines()):
                        if line_num == 1:
                            line_comps = line.split('\t')
                            runtime = float(line_comps[2])
                            runtimes[prefix_str] += runtime
                            break
        for key in runtimes.keys():
            print("{0}: {1}".format(key, round(runtimes[key] / files_for_avg,
                                               2)))
    except Exception:
        pass
