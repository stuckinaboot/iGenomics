from sys import argv

out = ''
with open(argv[1]) as file:
    for line in file.readlines():
        line = line.strip('\n').strip('\r')
        out += line + '\tAF=1\ttacos\n'

with open(argv[2], 'w') as file:
    file.write(out)
