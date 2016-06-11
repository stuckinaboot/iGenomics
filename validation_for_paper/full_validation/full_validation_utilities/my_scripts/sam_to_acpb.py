from sys import argv

samFile = open(argv[1], 'r')
outputFile = open(argv[2] + '.acpb', 'w')

#Process each line in the sam file
output = ""
for line in samFile.readlines():
	#If the line does not begin with an @, i.e. the line contains an alignment, then process the line
	
	lineDict = {}
	if line[0] != '@':
		components = line.split('\t')
		lineDict['readName'] = components[0]
		flag = int(components[1]) #4 = unmapped, 0 = forward, 16 = reverse
		if flag == 4:
			continue
		elif flag == 16:
			lineDict['direction'] = '-'
		else:
			lineDict['direction'] = '+'
		lineDict['segmentName'] = components[2]

		distanceStr = components[11]
		colonInDistStr = distanceStr.rfind(':')
		if colonInDistStr == -1:
                        print("Read lost: NM str missing colon")
                        continue
		else:
			lineDict['distance'] = distanceStr[(colonInDistStr + 1):]

		lineDict['position'] = components[3]

		output += lineDict['readName'] + '\t' + lineDict['position'] + '\t' + lineDict['segmentName'] + '\t' + lineDict['direction'] + '\t' + lineDict['distance'] + '\n'
outputFile.write(output)
outputFile.close()
