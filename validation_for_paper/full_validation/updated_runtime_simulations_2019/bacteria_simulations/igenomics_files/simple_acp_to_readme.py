import os
from sys import argv

CURR_PATH = os.path.abspath(argv[1])

def create_readme_if_needed(path):
    if os.path.isfile(path):
        if path.endswith('.data.acp'):
            # Create readme
            runtime = ''
            with open(path) as acp:
                for (i, line) in enumerate(acp.readlines()):
                    if i == 1:
                        comps = line.split('\t')
                        runtime = comps[2]
                        break
            with open(os.path.dirname(path) + '/README.dig', 'w+') as readme:
                readme.write('real\t0m' + str(runtime) + 's')
        return
    # call recursively
    for child in os.listdir(path):
        create_readme_if_needed(os.path.join(path, child))

for path in os.listdir(CURR_PATH):
    create_readme_if_needed(path)
