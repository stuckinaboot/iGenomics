from sys import argv

#Define constants
POSITION_MARGIN_OF_ERROR = 50
DISTANCE_MARGIN_OF_ERROR = 50

#Open the files
bwaFile = open(argv[1], 'r')
igenomicsFile = open(argv[2], 'r')

def printDivider():
	print("-----------------------------------------------------")

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
			print("ERROR: " + components[0] + " already occurred in DICT. Continuing...")
		dct[components[0]] = dictToAdd
	return dct

#Read the alignments into their respective lists
print("BEGIN LOADING: bwaAlignmentDict")
bwaAlignmentDict = alignmentsDictFromFile(bwaFile)
print("FINISHED LOADING: bwaAlignmentDict")
printDivider()
print("BEGIN LOADING: igenomicsAlignmentDict")
igenomicsAlignmentDict = alignmentsDictFromFile(igenomicsFile)
print("FINISHED LOADING: igenomicsAlignmentDict")
printDivider()

#Compare those lists, with respect to the constants
#NOTE: THIS PERFORMED WITH RESPECT TO THE ALIGNMENTS FOUND IN IGENOMICS
printDivider()
print("BEGIN COMPARING")
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
		if positionDifference > POSITION_MARGIN_OF_ERROR:
			passedAllTests = False
			reasonsForFailure['position'] = True
			print("ERROR: POSITION: " + readIGenomics + " margin of error was " + str(positionDifference))
		distanceDifference = abs(igenomicsDict['distance'] - bwaDict['distance'])
		if distanceDifference > DISTANCE_MARGIN_OF_ERROR:
			passedAllTests = False
			reasonsForFailure['distance'] = True
			print("ERROR: DISTANCE: " + readIGenomics + " margin of error was " + str(distanceDifference) + ". iGenomics had ED of " + str(igenomicsDict['distance']) + ". Official ED was " + str(bwaDict['distance']))
		if passedAllTests:
			passedReads.append(readIGenomics)
		else:
			failedReads.append({'read': readIGenomics, 'reasonsForFailure': reasonsForFailure})
	else:
		print("ERROR: " + readIGenomics + " not found in bwaDict. Continuing...")
		notSharedReads.append(readIGenomics)
		continue
print("FINISHED COMPARING")
printDivider()
print("RESULTS:")
print("PASSING READS: %d" % len(passedReads))
for read in passedReads:
	print("PASSED: " + read)
print("FAILING READS: %d" % len(failedReads))
for readDict in failedReads:
	print("FAILED: " + readDict['read'] + " --> " + str(readDict['reasonsForFailure']))
print("NOT SHARED READS:")
for read in notSharedReads:
	print("NOT SHARED: " + read)
print("RESULTS FINISHED")
