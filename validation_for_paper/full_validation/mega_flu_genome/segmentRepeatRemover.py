from sys import argv

out = ''
seenSegments = []
with open(argv[1]) as file:
	isSkipping = False
	for line in file.readlines():
		line = line.strip('\n').strip('\r')
		if '>' in line:
			isSkipping = False
			segName = line[1:line.find(' ')]
			if segName not in seenSegments:
				seenSegments.append(segName)
			else:
				isSkipping = True
		if isSkipping == False:
			out += line + '\n'

print seenSegments
with open(argv[2], 'w') as file:
	file.write(out)
