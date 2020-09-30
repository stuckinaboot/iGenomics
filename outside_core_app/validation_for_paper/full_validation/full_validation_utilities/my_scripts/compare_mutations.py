'''

Jist
-------
Comparing_mutations works on two .smf files, 
searching the second file inputted for every mutation in the first file inputted.

How comparing works
-------
*Compare chromosomes are the same
*Compare positions are the same
*Compare reference characters are the same
*Compare found characters are the same
*Compare type of mutation is the same

Notes
--------
mutDict keys are represented as follows: '{chromosome}>>{pos}'
'''

import sys
from sys import argv
import json

def mutDictFromFile(file):
	mutDict = {}
	for line in file.readlines():
		mut = json.loads(line)
		mutDict[mut['chromosome'] + '>>' + mut['pos'] + '>>' + mut['type']] = mut
	return mutDict

bwaFile = open(argv[1], 'r')
igenomicsFile = open(argv[2], 'r')

bwaMutDict = mutDictFromFile(bwaFile)
igenomicsMutDict = mutDictFromFile(igenomicsFile)

def compareMutations(mut1, mut2):
	# sys.stdout.write("comparing " + mut1['type'] + " and " + mut2['type'] + '\n')
	if mut1['type'] != mut2['type']:
		return "XX type comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	# sys.stdout.write("comparing " + mut1['ref'] + " and " + mut2['ref'] + '\n')
	if mut1['ref'] != mut2['ref']:
		return "XX ref comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	# sys.stdout.write("comparing " + mut1['found'] + " and " + mut2['found'] + '\n')
	if mut1['found'] != mut2['found']:
		return "XX found comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	if mut1['alleles'] != mut2['alleles']:
		return "XX alleles comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	return "passed"

def compareMutDicts():
	numPassed = 0
	numFailed = 0
	numNotShared = 0
	for key in bwaMutDict:
		if key in igenomicsMutDict:
			compareMutStr = compareMutations(bwaMutDict[key], igenomicsMutDict[key])
			if compareMutStr == 'passed':
				sys.stdout.write("PASSED: " + key + '\n')
				numPassed += 1
			else:
				sys.stdout.write("FAIL: " + key + " " + compareMutStr + '\n')
				numFailed += 1
		else:
			sys.stdout.write("FAIL: " + key + " not found" + '\n')
			numNotShared += 1
	sys.stdout.write("_______________________________________\n")
	sys.stdout.write("~~CONCISE REPORT~~\n")
	sys.stdout.write("TYPE: Mutations\n")
	sys.stdout.write("PASSED: " + str(numPassed) + '\n')
	sys.stdout.write("FAILED: " + str(numFailed) + '\n')
	sys.stdout.write("NOT SHARED: " + str(numNotShared) + '\n')
	sys.stdout.write("LEN iG: " + str(len(igenomicsMutDict)) + '\n')
	sys.stdout.write("LEN BWA: " + str(len(bwaMutDict)) + '\n')

compareMutDicts()