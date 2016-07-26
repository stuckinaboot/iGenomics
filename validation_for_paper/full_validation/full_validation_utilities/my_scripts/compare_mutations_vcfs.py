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

APPROXI_POS_MARGIN = 5

def mutDictFromFile(file):
	mutDict = {}
	header = []
	for line in file.readlines():
		line = line.strip('\n')
		if len(line) > 1:
			if line[0] == '#' and line[1] != '#':
				header = line.split('\t')
				header[0] = header[0][1:]
			elif line[0] != '#': 
				components = line.split('\t')
				mut = {}
				
				#Generate mutation dictionary
				for i, comp in enumerate(components):
					mut[header[i]] = comp

				if 'mt' in mut['INFO']:
					mut['TYPE'] = mut['INFO'][mut['INFO'].find('mt') + 3 :]
					mut['TYPE'] = mut['TYPE'][:3]

					if 'AF=1.0':
						mut['ALLELES'] = 'HOM'
					else:
						mut['ALLELES'] = 'HET'
				else:
					#Separate multiple refs and alts into lists
					mut['ALT'] = mut['ALT'].split(',')
					mut['REF'] = mut['REF'].split(',')

					#Generate a type for the mutation
					if len(mut['ALT'][0]) > 1:
						mut['TYPE'] = 'INS'
					elif len(mut['REF'][0]) > 1:
						mut['TYPE'] = 'DEL'
					else:
						mut['TYPE'] = 'SUB'

					#Generate a heterozygosity val for the mutation
					if len(mut['ALT']) > 1 or len(mut['REF']) > 1:
						mut['ALLELES'] = 'HET'
					else:
						mut['ALLELES'] = 'HOM'

					#Convert the lists into single strings (as the DWGSIM file has only one ALT even if hetero)
					mut['ALT'] = mut['ALT'][0]
					mut['REF'] = mut['REF'][0]
				mutDict[mut['CHROM'] + '>>' + mut['POS'] + '>>' + mut['TYPE']] = mut
	return mutDict

bwaFile = open(argv[1], 'r')
igenomicsFile = open(argv[2], 'r')

bwaMutDict = mutDictFromFile(bwaFile)
igenomicsMutDict = mutDictFromFile(igenomicsFile)

def compareMutations(mut1, mut2):
	if mut1['TYPE'] != mut2['TYPE']:
		return "XX type comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	if mut1['REF'] != mut2['REF']:
		return "XX ref comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	if mut1['ALLELES'] != mut2['ALLELES']:
		return "XX alleles comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	if mut1['ALT'] != mut2['ALT']:
		#Leave the next if in if we want to allow one by one sensible insertions
		# if mut1['TYPE'] != 'INS' or not(mut1['ALT'][1:] == mut2['ALT'] and mut1['ALT'][0] == mut2['ALT'][0]):
		return "XX found comparison -> 1: " + str(mut1) + "| 2: " + str(mut2)
	return "passed"

def findApproximateMutationWithMargin(mutationDict, margin, targetMutation):
	for mutationKey in mutationDict:
		mutation = mutationDict[mutationKey]
		if mutation['CHROM'] == targetMutation['CHROM'] and mutation['TYPE'] == targetMutation['TYPE']:
			if abs(int(mutation['POS']) - int(targetMutation['POS'])) <= margin:
				return mutationKey
	return None

def compareMutDicts():
	numPassed = 0
	numFailed = 0
	numNotShared = 0
	numApproxiPassed = 0

	bwaMutDictRemainder = bwaMutDict.copy()
	igenomicsMutDictRemainder = igenomicsMutDict.copy()

	failedList = []

	for key in bwaMutDict:
		if key in igenomicsMutDict:
			compareMutStr = compareMutations(bwaMutDict[key], igenomicsMutDict[key])
			if compareMutStr == 'passed':
				sys.stdout.write("PASSED: " + key + '\n')
				numPassed += 1
				bwaMutDictRemainder.pop(key)
				igenomicsMutDictRemainder.pop(key)
			else:
				sys.stdout.write("FAIL: " + key + " " + compareMutStr + '\n')
				numFailed += 1
				failedList.append(key)
		else:
			sys.stdout.write("FAIL: " + key + " not found" + '\n')
			numNotShared += 1


	finalRemainder = bwaMutDictRemainder.keys()

	print numNotShared
	print numFailed
	for key in bwaMutDictRemainder:
		approxiMutKey = findApproximateMutationWithMargin(igenomicsMutDictRemainder, APPROXI_POS_MARGIN, bwaMutDictRemainder[key])
		if approxiMutKey is not None:
			numPassed += 1
			numApproxiPassed += 1
			sys.stdout.write("PASSED (Approxi): " + key + '\n')
			igenomicsMutDictRemainder.pop(approxiMutKey)
			try:
				failedList.remove(key)
				numFailed -= 1
			except:
				#Not in failedList, so it must of been in not shared
				numNotShared -= 1
			# if key in finalRemainder:
			finalRemainder.remove(key)
			# approxiMutKey = findApproximateMutationWithMargin(igenomicsMutDictRemainder, 5, bwaMutDictRemainder[key])

	for key in finalRemainder:
		print "FAIL: " + key + " still not found"
	for key in failedList:
		print "FAIL: " + key + " still failed"

	sys.stdout.write("_______________________________________\n")
	sys.stdout.write("~~CONCISE REPORT~~\n")
	sys.stdout.write("TYPE: Mutations\n")
	sys.stdout.write("PASSED: " + str(numPassed) + '\n')
	sys.stdout.write("PASSED (Approxi): " + str(numApproxiPassed) + '\n')
	sys.stdout.write("FAILED: " + str(numFailed) + '\n')
	sys.stdout.write("NOT SHARED: " + str(numNotShared) + '\n')
	sys.stdout.write("LEN iG: " + str(len(igenomicsMutDict)) + '\n')
	sys.stdout.write("LEN BWA: " + str(len(bwaMutDict)) + '\n')

compareMutDicts()