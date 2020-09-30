from sys import argv

out = '#CHROM\tPOS\tREF\tALT\n'
with open(argv[1]) as file:
    for line in file.readlines():
        line = line.strip('\r').strip('\n')
        components = line.split('\t')
        out += components[0] + '\t' + components[1] + '\t'
        if components[2] == '.':
            #insertion
            out += components[2] + '\t' + 2*components[3]
        elif components[3] == '.':
            out += 2*components[2] + '\t' + components[2]
        else:
            out += components[2] + '\t' + components[3]
        out += '\n'

with open(argv[2], 'w') as file:
    file.write(out)
