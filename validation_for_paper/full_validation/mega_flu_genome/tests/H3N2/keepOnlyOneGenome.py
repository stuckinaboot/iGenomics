from sys import argv

out = ''
keyword = argv[1]
with open(argv[2]) as file:
	shouldAddToOutput = False
	for line in file.readlines():
		line = line.strip('\n').strip('\r')
		if '>' in line:
			if keyword in line:
				shouldAddToOutput = True
			else:
				shouldAddToOutput = False
		if shouldAddToOutput:
			out += line + '\n'

with open(argv[3], 'w') as file:
	file.write(out)