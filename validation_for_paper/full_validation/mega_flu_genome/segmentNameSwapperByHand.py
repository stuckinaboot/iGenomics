from sys import argv
import os

out = ''
with open(argv[1]) as file:
	for line in file.readlines():
		line = line.strip('\n').strip('\r')
		if '>' in line:
			components = line[1:].split(' ')
			os.system('clear')
			for i, component in enumerate(components):
				print str(i) + '::' + component
			firstToSwap = int(raw_input('First to swap: '))
			secondToSwap = int(raw_input('Second to swap: '))

			temp = components[firstToSwap]
			components[firstToSwap] = components[secondToSwap]
			components[secondToSwap] = temp
			out += '>' + " ".join(components)
		else:
			out += line
		out += '\n'

with open(argv[2], 'w') as file:
	file.write(out)
