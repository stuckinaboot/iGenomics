from sys import argv
acpFile = open(argv[1], 'r')
acpbFile = open(argv[2] + '.acpb', 'w')

output = ""
print(argv[1])
for line in acpFile.readlines():
	line = line.strip('\n')
	if (len(line) > 0 and line[0] == '#'):
		continue
	if (len(line) == 0):
		continue
	comp = line.split('\t')

	for i in range(0, 5):
		output += comp[i]
		if (i < 4):
			output += '\t'
	output += '\n'
acpbFile.write(output)
acpbFile.close()
acpFile.close()
