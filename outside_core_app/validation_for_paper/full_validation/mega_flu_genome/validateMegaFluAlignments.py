from sys import argv
import sys

print 'alignments file, ref file alignments were simulated from'

alignmentsFilePath = argv[1]
print alignmentsFilePath

refFilePath = argv[2]

passingSegments = []

#Determine list of passing segment
with open(refFilePath) as ref:
	for line in ref.readlines():
		line = line.strip('\r').strip('\n')
		if '>' in line:
			passingSegments.append(line)

passing = 0
total = 0

alignmentsFileInfo = {}
keysInOrder = []
with open(alignmentsFilePath) as alignments:
	for line in alignments.readlines():
		line = line.strip('\r').strip('\n')
		if len(line) > 0 and line[0] != '#':
			currSeg = line.split('\t')[2]
			for seg in passingSegments:
				if currSeg in seg:
					passing += 1
					break
			total += 1
		elif len(line) > 0 and line[0] == '#':
			components = line.split('\t')
			if len(keysInOrder) > 0:
				for i, key in enumerate(keysInOrder):
					alignmentsFileInfo[key] = components[i]
			else:
				keysInOrder = components
print alignmentsFileInfo
sys.stdout.write('Aligning Runtime:   ' + alignmentsFileInfo['RT'] + '\n')
sys.stdout.write('Aligning Rate:      ' + str(float(alignmentsFileInfo['ARC']) / float(alignmentsFileInfo['RC'])) + '\n')
sys.stdout.write('Alignments Passing: ' + str(passing) + '\n')
sys.stdout.write('Alignments Total:   ' + str(total) + '\n')
sys.stdout.write('Alignments Passing Rate:   ' + str(float(passing)/float(total)) + '\n\n')

