import sys
from sys import argv

#Define constants
POSITION_MARGIN_OF_ERROR = 50
DISTANCE_MARGIN_OF_ERROR = 50

if len(argv) == 4:
	POSITION_MARGIN_OF_ERROR = int(argv[3])
elif len(argv) == 5:
	POSITION_MARGIN_OF_ERROR = int(argv[3])
	DISTANCE_MARGIN_OF_ERROR = int(argv[4])

#Open the files
bwaFile = open(argv[1], 'r')
igenomicsFile = open(argv[2], 'r')

def printDivider():
	sys.stdout.write("-----------------------------------------------------" + '\n')

def alignmentsDictFromFile(file):
	dct = {}
	for line in file.readlines():
		line = line.strip('\n')
		components = line.split('\t')
		dictToAdd = {}
		dictToAdd['read name'] = components[0]
		dictToAdd['position'] = int(components[1])
		dictToAdd['segment name'] = components[2]
		dictToAdd['direction'] = components[3]
		dictToAdd['distance'] = int(components[4])
		if components[0] in dct:
			sys.stdout.write("ERROR: " + components[0] + " already occurred in DICT. Continuing..." + '\n')
		dct[components[0]] = dictToAdd
	return dct

def alignmentsDictFromDWGReadsFile(file):
	dct = {}
	i = 0
	for line in file.readlines():
		if i % 4 == 0:
			line = line.strip('\n')[1:]
			components = line.split('_')
			dictToAdd = {}
			dictToAdd['read name'] = line
			dictToAdd['position'] = int(components[1])
			dictToAdd['segment name'] = components[0]
			dictToAdd['direction'] = '+' if (components[3] == '0') else '-'
			distComponents = components[7].split(':')
			dictToAdd['distance'] = int(distComponents[0]) + int(distComponents[1]) + int(distComponents[2]) #number of SNPs, number of indels, number of sequencing errors
			if line in dct:
				sys.stdout.write("ERROR: " + components[0] + " already occurred in DICT. Continuing..." + '\n')
			dct[line] = dictToAdd
		i += 1
	return dct
#Read the alignments into their respective lists
sys.stdout.write("BEGIN LOADING: bwaAlignmentDict" + '\n')
bwaAlignmentDict = None
if '.fastq' in argv[1] or '.fq' in argv[1]:
	bwaAlignmentDict = alignmentsDictFromDWGReadsFile(bwaFile)
else:
	bwaAlignmentDict = alignmentsDictFromFile(bwaFile)

sys.stdout.write("FINISHED LOADING: bwaAlignmentDict" + '\n')
printDivider()
sys.stdout.write("BEGIN LOADING: igenomicsAlignmentDict" + '\n')
igenomicsAlignmentDict = alignmentsDictFromFile(igenomicsFile)
sys.stdout.write("FINISHED LOADING: igenomicsAlignmentDict" + '\n')
printDivider()

#Compare those lists, with respect to the constants
#NOTE: THIS PERFORMED WITH RESPECT TO THE ALIGNMENTS FOUND IN IGENOMICS
printDivider()
sys.stdout.write("BEGIN COMPARING" + '\n')
passedReads = []
failedReads = []
notSharedReads = []
for readIGenomics in igenomicsAlignmentDict:
	igenomicsDict = igenomicsAlignmentDict[readIGenomics]
	if readIGenomics in bwaAlignmentDict:
		bwaDict = bwaAlignmentDict[readIGenomics]
		passedAllTests = bwaDict['direction'] == igenomicsDict['direction']
		reasonsForFailure = {}
		reasonsForFailure['position'] = False
		reasonsForFailure['distance'] = False
		positionDifference = abs(igenomicsDict['position'] - bwaDict['position'])
		if positionDifference > POSITION_MARGIN_OF_ERROR or bwaDict['segment name'] != igenomicsDict['segment name']:
			passedAllTests = False
			reasonsForFailure['position'] = True
			sys.stdout.write("ERROR: POSITION: " + readIGenomics + " margin of error was " + str(positionDifference) + '\n')
		distanceDifference = abs(igenomicsDict['distance'] - bwaDict['distance'])
		if distanceDifference > DISTANCE_MARGIN_OF_ERROR:
			passedAllTests = False
			reasonsForFailure['distance'] = True
			sys.stdout.write("ERROR: DISTANCE: " + readIGenomics + " margin of error was " + str(distanceDifference) + ". iGenomics had ED of " + str(igenomicsDict['distance']) + ". Official ED was " + str(bwaDict['distance']) + '\n')
		if passedAllTests:
			passedReads.append(readIGenomics)
		else:
			failedReads.append({'read': readIGenomics, 'reasonsForFailure': reasonsForFailure})
	else:
		sys.stdout.write("ERROR: " + readIGenomics + " not found in bwaDict. Continuing..." + '\n')
		notSharedReads.append(readIGenomics)
		continue
sys.stdout.write("FINISHED COMPARING" + '\n')
printDivider()
sys.stdout.write("RESULTS:" + '\n')
sys.stdout.write("PASSING READS: %d\n" % len(passedReads))
for read in passedReads:
	sys.stdout.write("PASSED: " + read + '\n')
sys.stdout.write("FAILING READS: %d\n" % len(failedReads))
for readDict in failedReads:
	sys.stdout.write("FAILED: " + readDict['read'] + " --> " + str(readDict['reasonsForFailure']) + '\n')
sys.stdout.write("NOT SHARED READS:" + '\n')
for read in notSharedReads:
	sys.stdout.write("NOT SHARED: " + read + '\n')
sys.stdout.write("_______________________________________\n")
sys.stdout.write("~~CONCISE REPORT~~\n")
sys.stdout.write("TYPE: Alignments\n")
sys.stdout.write("PASSED: " + str(len(passedReads)) + '\n')
sys.stdout.write("FAILED: " + str(len(failedReads)) + '\n')
sys.stdout.write("NOT SHARED: " + str(len(notSharedReads)) + '\n')
sys.stdout.write("LEN iG: " + str(len(igenomicsAlignmentDict)) + '\n')
sys.stdout.write("LEN BWA: " + str(len(bwaAlignmentDict)) + '\n')
sys.stdout.write("RESULTS FINISHED\n")
