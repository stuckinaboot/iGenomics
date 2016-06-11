from sys import argv
import json
vcfFile = open(argv[1], 'r')
outputExt = '.smf'
output = ""
for line in vcfFile.readlines():
	if line[0] == '#':
		continue
	mutationDict = {}
	components = line.split('\t')
	mutationDict['chromosome'] = components[0]
	mutationDict['pos'] = components[1]
	mutationDict['ref'] = components[3]
	mutationDict['found'] = components[4]
	
	indexOfLastEquals = components[7].rfind('=')
	mutTypeLong = components[7][(indexOfLastEquals + 1):]
	mutTypeShort = mutTypeLong[:3]
	mutationDict['type'] = mutTypeShort

	if mutTypeShort == 'DEL':
		mutationDict['ref'] = mutationDict['ref'][1:] #Doesn't include the reference base that was NOT deleted, so remove the ref char and add up to pos to account for removing that char 
		mutationDict['found'] = '-'
		mutationDict['pos'] = str(int(mutationDict['pos']) + 1)

	indexOfFirstEquals = components[7].find('=')
	indexOfSemicolon = components[7].find(';')
	alleleFreq = float(components[7][indexOfFirstEquals + 1:indexOfSemicolon])
	homoHeteroStr = ''
	if alleleFreq == 1:
		homoHeteroStr = '*'
	else:
		homoHeteroStr = '&'
	mutationDict['alleles'] = homoHeteroStr

	output += json.dumps(mutationDict) + '\n'
outputFile = open(argv[2] + outputExt , 'w')
outputFile.write(output)
outputFile.close()