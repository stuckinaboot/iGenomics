import sys
import os
from os import listdir
from os.path import isfile, join
from sys import argv

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

def createFolderTreeFromiGenomicsSimFiles(fileNames, path):
	stdPrint('	Create Folder Tree: Entering tree build loop')
	for fileName in fileNames:
		currPath = path
		nameComponents = fileName.split('-')
		nameDict = {'read_len': nameComponents[1][2:], 'seq_error_rate': nameComponents[2][2:], 'mut_rate': nameComponents[3][2:nameComponents[3].find('.fq')]}
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
			os.system('mv ' + path + fileName + ' ' + currPath + 'reads.mutations.mcs')

		readMeFilePath = currPath + 'README.dig'

		#Remove the junk from the top of the file
		simInfo = ''

		runtime = ''
		stdPrint('adsfajsfjklaslkfd')
		with open(currPath + 'reads.acp', 'r') as dataFile:
			i = 0
			stdPrint('adsfajsfjklaslkfd')
			for line in dataFile.readlines():
				if i == 1:
					components = line.split('\t')
					runtime = components[2]
					stdPrint('adsfajsfjklaslkfd')
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

	path = argv[1]
	stdPrint('Auto iGenomics Folder Tree: Obtaining files in ' + path)

	#http://stackoverflow.com/questions/3207219/how-to-list-all-files-of-a-directory-in-python
	filesInDirectory = [f for f in listdir(path) if isfile(join(path, f))]

	stdPrint('Auto iGenomics Folder Tree: Starting folder tree generation')
	printDivider()
	createFolderTreeFromiGenomicsSimFiles(filesInDirectory, path)
	printDivider()
	stdPrint('Auto iGenomics Folder Tree: Finished folder tree generation')

if __name__ == "__main__":
	main()