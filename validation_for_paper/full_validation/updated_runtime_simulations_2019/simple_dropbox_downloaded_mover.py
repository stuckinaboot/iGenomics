import os
from sys import argv

CURR_PATH = os.path.abspath(argv[1])

for file_name in os.listdir(CURR_PATH):
    file_path = CURR_PATH + '/' + file_name
    # print(file_path)
    if os.path.isfile(file_path) and file_path.endswith('.data.acp'):
        comps = file_name[0:file_name.index('.data.acp')].split('-')
        dest_dir = CURR_PATH + '/'
        for comp in comps:
            if comp != 'reads':
                if comp.startswith('rl'):
                    dest_dir += 'read_len' + comp[2:] + 'bp'
                else:
                    dest_dir += comp
                dest_dir += '/'
        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)
        os.rename(file_path, dest_dir + file_name)
