from sys import argv

out = ''
seenSegments = []
with open(argv[1]) as file:
	isSkipping = False
	for line in file.readlines():
		line = line.strip('\n').strip('\r')
		if '>' in line and '(NA)' not in line and '(HA)' not in line:
			isSkipping = False
			components = line.split(' ')
			indexOfLastStartParanthesis = line.rfind('(')
			indexOfLastEndParanthesis = line.rfind(')')
			segName = line[indexOfLastStartParanthesis:indexOfLastEndParanthesis + 1]
			if segName not in seenSegments:
				seenSegments.append(segName)
			else:
				isSkipping = True
		if isSkipping == False:
			out += line + '\n'

with open(argv[2], 'w') as file:
	file.write(out)
