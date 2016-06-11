from sys import argv
import json
import re
mcsFile = open(argv[1], 'r')
outputExt = '.smf'

mutationsList = []
i = 0
for line in mcsFile.readlines():
	if (i == 0):
		i += 1
		continue

	components = line.split('\t')
	pos = components[0]
	refChar = components[1][0]
	
	coverageStrs = re.findall("\[(.*?)\]", components[2])
	coverageDict = {}
	for coverageStr in coverageStrs:
		coverageStrComponents = coverageStr.split('=')
		if coverageStrComponents[0] != '+':
			coverageDict[coverageStrComponents[0]] = coverageStrComponents[1]
		else:
			insStrs = re.findall("\{(.*?)\}", coverageStr[2:])
			insDict = {}
			for insStr in insStrs:
				insComponents = insStr.split('=')
				insDict[insComponents[0]] = insComponents[1]
			coverageDict['+'] = insDict

	foundCharWithHighestFrequency = "" #Can't be the reference char
	highestFrequency = 0

	alleleFreq = 1.0 / len(coverageDict)
	homoHeteroStr = ''
	if alleleFreq == 1:
		homoHeteroStr = '*';
	else:
		homoHeteroStr = '&';
	for char in coverageDict:
		if char == refChar:
			continue
		if char == "+":
			insDict = coverageDict[char]
			for insKey in insDict:
				if (int(insDict[insKey]) > highestFrequency):
					foundCharWithHighestFrequency = char + insKey
					highestFrequency = int(insDict[insKey])
		elif int(coverageDict[char]) > highestFrequency:
			foundCharWithHighestFrequency = char
			highestFrequency = int(coverageDict[char])


	mutation = {'pos': components[0], 'ref': refChar, 'chromosome': components[3].strip('\n')}
	mutation['alleles'] = homoHeteroStr
	if foundCharWithHighestFrequency == "-":
		mutation['type'] = "DEL"
	elif "+" in foundCharWithHighestFrequency:
		foundCharWithHighestFrequency = refChar + foundCharWithHighestFrequency.strip('+')
		mutation['type'] = "INS"
	else:
		mutation['type'] = "SUB"
	mutation['found'] = foundCharWithHighestFrequency
	mutationsList.append(mutation)

outputFile = open(argv[2] + outputExt, 'w')
output = ""
i = 0
while i < len(mutationsList):
	mutation = mutationsList[i]
	#Compress deletions
	if mutation['type'] == "DEL":
		compressedChars = mutation['ref']
		j = i + 1
		prevPos = int(mutation['pos'])
		while j < len(mutationsList):
			nextMutation = mutationsList[j]
			if nextMutation['type'] == "DEL" and nextMutation['chromosome'] == mutation['chromosome'] and int(nextMutation['pos']) == prevPos + 1:
				compressedChars += nextMutation['ref']
				prevPos = int(nextMutation['pos'])
				mutationsList.remove(nextMutation)
			else:
				break
		mutation['ref'] = compressedChars
	output += json.dumps(mutation) + '\n'
	i += 1
outputFile.write(output)
outputFile.close()




