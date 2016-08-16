from sys import argv
import os

out = ''
with open(argv[1]) as file:
	for line in file.readlines():
		line = line.strip('\n').strip('\r')
		if '>' in line:
			components = line[1:].split(' ')
			firstToSwap = 0
			secondToSwap = 1

			temp = components[firstToSwap]
			components[firstToSwap] = components[secondToSwap]
			components[secondToSwap] = temp
			out += '>' + " ".join(components)
		else:
			out += line
		out += '\n'

with open(argv[2], 'w') as file:
	file.write(out)
