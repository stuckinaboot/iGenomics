from sys import argv
import os

for directory in argv[1:]:
    os.system('rm -rf ' + directory + 'read_len1000bp/seq_error_rate0.01')
    os.system('rm -rf ' + directory + 'read_len100bp/seq_error_rate0.1')
    files = os.listdir(directory)
    for f in files:
        if 'reads-rl1000-se0.01' in f or 'reads-rl100-se0.1' in f:
            os.system('rm -rf ' + directory + f)
