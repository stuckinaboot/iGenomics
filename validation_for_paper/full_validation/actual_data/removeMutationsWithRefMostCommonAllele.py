from sys import argv

print 'mutations file path, mutations file with ref most common alleles removed path\n\n\n'

out = ''

with open(argv[1]) as file:
	for line in file.readlines():
		line = line.strip('\r').strip('\n')
		if len(line) > 0 and line[0] == '#':
			out += line + '\n'
			continue
		components = line.split('\t')
		refBase = components[3]

		afField = components[7]
		afFieldComponents = afField.split(',')
		mostCommonBase = afFieldComponents[len(afFieldComponents) - 1]
		if refBase[0] == mostCommonBase:
			continue
		else:
			out += line + '\n'

out = out.strip('\n')

with open(argv[2], 'w') as file:
	file.write(out)