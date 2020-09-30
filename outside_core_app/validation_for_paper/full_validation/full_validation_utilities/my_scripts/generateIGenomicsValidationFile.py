from sys import argv
import sys

FILE_REPORT_INDICATOR = '~~CONCISE REPORT~~'

i = len(argv) - 1
comparisonFiles = []
while i > 0:
	comparisonFiles.append(open(argv[i], 'r'))
	i -= 1

totalDict = {'type': 'Summary', 'passed': 0, 'failed': 0, 'not_shared': 0, 'iglen': 0, 'bwalen': 0}
def generateOutputForDataDict(dataDict):
	output = "VT: " + dataDict['type'] + '\n'
	totalAmtOfComparisonData = int(dataDict['passed']) + int(dataDict['failed']) + int(dataDict['not_shared'])
	totalDict['passed'] += int(dataDict['passed'])
	totalDict['failed'] += int(dataDict['failed'])
	totalDict['not_shared'] += int(dataDict['not_shared'])
	totalDict['iglen'] += int(dataDict['iglen'])
	totalDict['bwalen'] += int(dataDict['bwalen'])
	output += 'P\tF\tNS\tT\n'
	output += dataDict['passed'] + '\t' + dataDict['failed'] + '\t' + dataDict['not_shared'] + '\t' + str(totalAmtOfComparisonData) + '\n'
	output += str(round(float(dataDict['passed']) / totalAmtOfComparisonData, 4)) + '\t' + str(round(float(dataDict['failed']) / totalAmtOfComparisonData, 4)) + '\t' + str(round(float(dataDict['not_shared']) / totalAmtOfComparisonData, 4)) + '\n'
	output += 'iG: ' + dataDict['iglen'] + '\t' + 'BWA: ' + dataDict['bwalen']
	return output

for file in comparisonFiles:
	startFillingDict = False
	dataDict = {}
	for line in file.readlines(): 
		if FILE_REPORT_INDICATOR in line:
			startFillingDict = True
		elif startFillingDict:
			line = line.strip('\n')
			if 'TYPE: ' in line:
				dataDict['type'] = line.split(' ')[1]
			elif 'FAILED: ' in line:
				dataDict['failed'] = line.split(' ')[1]
			elif 'PASSED: ' in line:
				dataDict['passed'] = line.split(' ')[1]
			elif 'NOT SHARED: ' in line:
				dataDict['not_shared'] = line.split(' ')[2]
			elif 'LEN iG: ' in line:
				dataDict['iglen'] = line.split(' ')[2]
			elif 'LEN BWA: ' in line:
				dataDict['bwalen'] = line.split(' ')[2]
			if len(dataDict) == 6:
				output = generateOutputForDataDict(dataDict)
				sys.stdout.write(output + '\n____________________________\n')
				break
cumulativeDict = {}
for key in totalDict:
	cumulativeDict[key] = str(totalDict[key])
sys.stdout.write(generateOutputForDataDict(cumulativeDict) + '\n')
