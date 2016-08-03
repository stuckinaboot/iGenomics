from sys import argv
import os
import json

'''
Concise Report File Format (.crf):
Contains a JSON object on each line that looks like the following:
	{
		'reference': reference genome name,
		'read length': read length (all info can be deducted from this),
		'reference length': reference file length,
		'number of reads' : number of reads,
		'mutation accuracy': mutation comparison accuracy,
		'iGenomics runtime': iG runtime,
		'bwa runtime': BWA runtime
	}
	where each JSON object represents one genome
'''

COMPARE_MUTS_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/my_scripts/compare_mutations_vcfs.py'

def createDirectoryAtPath(path):
	try:
		os.makedirs(path)
	except:
		pass

currPath = os.path.abspath(argv[1])
dwgPath = os.path.abspath(argv[2]) #Should be the path to the directory containing all the gen output folders
igPath = os.path.abspath(argv[3]) #Should be the path to the directory containing the tree of iGenomics output folders
currPath = os.path.join(currPath, 'concise_reports')

createDirectoryAtPath(currPath)

def acpFileToDict(filePath):
	info = {}
	with open(filePath) as file:
		keys = []
		for i, line in enumerate(file.readlines()):
			if i == 0:
				keys = line.split('\t')
			elif i == 1:
				values = line.split('\t')
				for key, value in zip(keys, values):
					info[key] = value
				return info

def runtimeFromREADMEdig(readmeDigPath):
	with open(readmeDigPath) as file:
		runtimeLine = file.readline()
		runtimeStr = runtimeLine.split('\t')[1].strip('s\n')
		runtimeComponents = runtimeStr.split('m')
		actualRuntime = int(runtimeComponents[0]) * 60.0 + float(runtimeComponents[1])
		return actualRuntime

def accuracyFromMutsOutFile(mutFilePath):
	with open(mutFilePath) as file:
		info = {}
		for line in file.readlines():
			if ('PASSED:' in line and '>>' not in line) or 'LEN' in line:
				components = line.split(': ')
				info[components[0]] = int(components[1])
		recall = float(info['PASSED']) / info['LEN BWA']
		precision = float(info['PASSED']) / info['LEN iG']
		accuracy = (2 * precision * recall) / float(precision + recall)
		return accuracy

for igFolder in os.listdir(igPath):
	currIGPath = os.path.join(igPath, igFolder)

	dwgFolder = 'generation_output_' + igFolder.replace('.fa', '')
	currDWGPath = os.path.join(dwgPath, dwgFolder)
	for readLenPath in os.listdir(currIGPath):
		infoDict = {
					'read len': readLenPath.strip('read_len').strip('bp'),
					'reference': igFolder
					}
		
		currIGPath = os.path.join(os.path.join(igPath, igFolder), readLenPath)
		igFolderFiles = []
		for (dirpath, dirnames, filenames) in os.walk(currIGPath):
			igFolderFiles.extend([os.path.join(dirpath, name) for name in filenames])
		
		currDWGPath = os.path.join(os.path.join(dwgPath, dwgFolder), readLenPath)
		dwgFolderFiles = []
		for (dirpath, dirnames, filenames) in os.walk(currDWGPath):
			dwgFolderFiles.extend([os.path.join(dirpath, name) for name in filenames])

		igMutationsFilePath = ''
		for filePath in igFolderFiles:
			if '.acp' in filePath:
				acpDict = acpFileToDict(filePath)
				infoDict['iGenomics runtime'] = acpDict['RT']
				infoDict['number of reads'] = acpDict['RC']
			elif '.normalized.ig.vcf' in filePath:
				igMutationsFilePath = filePath

		dwgMutationsFilePath = ''
		for filePath in dwgFolderFiles:
			if '.normalized.dwg.vcf' in filePath:
				dwgMutationsFilePath = filePath
			elif 'README.dig' in filePath:
				infoDict['bwa runtime'] = runtimeFromREADMEdig(filePath)

		mutsOutPath = os.path.join(currPath, 'muts.out')
		os.system('python ' + COMPARE_MUTS_PATH + ' ' + dwgMutationsFilePath + ' ' + igMutationsFilePath + ' > ' + mutsOutPath)
		infoDict['mutation accuracy'] = accuracyFromMutsOutFile(mutsOutPath)
		os.system('rm ' + mutsOutPath)
		print infoDict








