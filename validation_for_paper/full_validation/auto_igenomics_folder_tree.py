import sys
import os
from os import listdir
from os.path import isfile, join
from sys import argv

NORM_PATH = './full_validation_utilities/vcf_tools/vt/vt'
NORM_CMD_FORMAT = ' normalize -o %s -r %s %s'

def createDirectoryAtPath(path):
    try:
        os.makedirs(path)
        stdPrint('	Create Directory At Path: Dir created - ' + path)
    except:
    	stdPrint('	Create Directory At Path: Already exists - ' + path)

def stdPrint(txt):
	sys.stdout.write(txt + '\n')

def printDivider():
	stdPrint('____________________________________________________________________________________________________')

def normalize(referenceFilePath, mutFilePath, mutNormalizedFilePath):
	normalizeCmd = NORM_PATH + NORM_CMD_FORMAT % (mutNormalizedFilePath, referenceFilePath, mutFilePath)
	print normalizeCmd
	os.system(normalizeCmd)

def createFolderTreeFromiGenomicsSimFiles(fileNames, refFilePath, path):
	stdPrint('	Create Folder Tree: Entering tree build loop')
	for fileName in fileNames:
		currPath = path
		nameComponents = fileName.split('-')
		nameDict = {'read_len': nameComponents[1][2:], 'seq_error_rate': nameComponents[2][2:], 'mut_rate': nameComponents[3][2:max(nameComponents[3].find('.var'), nameComponents[3].find('.data'))]}
		stdPrint('		Tree build loop: nameDict created')

		currPath += 'read_len' + nameDict['read_len'] + 'bp' + '/'
		createDirectoryAtPath(currPath)

		currPath += 'seq_error_rate' + nameDict['seq_error_rate'] + '/'
		createDirectoryAtPath(currPath)

		currPath += 'mut_rate' + nameDict['mut_rate'] + '/'
		createDirectoryAtPath(currPath)
		stdPrint('		Tree build loop: folder subtree created')
		
		if 'data' in fileName:
			os.system('mv ' + path + fileName + ' ' + currPath + 'reads.acp')
		elif 'var' in fileName:
			os.system('mv ' + path + fileName + ' ' + currPath + 'reads.mutations.ig.vcf')
			normalize(refFilePath, currPath + 'reads.mutations.ig.vcf', currPath + 'reads.mutations.normalized.ig.vcf')

		readMeFilePath = currPath + 'README.dig'

		#Remove the junk from the top of the file
		if 'data' in fileName:
			simInfo = ''

			runtime = ''
			with open(currPath + 'reads.acp', 'r') as dataFile:
				i = 0
				for line in dataFile.readlines():
					if i == 1:
						components = line.split('\t')
						runtime = components[2]
						break
					i += 1

			with open(readMeFilePath, 'w') as readMeFile:
				simInfo += 'real\t' + runtime + '\n'
				readMeFile.write(simInfo)


		stdPrint('		Tree build loop: ' + fileName + ' successfully moved')
	stdPrint('	Create Folder Tree: Finished tree build loop')

def main():
	os.system('clear')
	stdPrint('Auto iGenomics Folder Tree: Started')
	printDivider()

	refFilePath = argv[1]
	path = argv[2]

	stdPrint('Auto iGenomics Folder Tree: Obtaining files in ' + path)

	#http://stackoverflow.com/questions/3207219/how-to-list-all-files-of-a-directory-in-python
	filesInDirectory = [f for f in listdir(path) if isfile(join(path, f))]

	stdPrint('Auto iGenomics Folder Tree: Starting folder tree generation')
	printDivider()
	createFolderTreeFromiGenomicsSimFiles(filesInDirectory, refFilePath, path)
	printDivider()
	stdPrint('Auto iGenomics Folder Tree: Finished folder tree generation')

if __name__ == "__main__":
	main()
