'''
|Algorithm|
    Read in parameters
    Perform simulation using the parameters as input to DWGSIM:
        Remove all files other than the BWA read1 file and the reads mutations vcf file
        Create empty README.siminfo file
        Create a temporary folder:
            Perform BWA alignment with runtime recording
            Record runtime and parameters in README.siminfo file
            Remove all BWA files:
                Delete temporary folder
'''
import sys
import os

DWGSIM_PATH = './full_validation_utilities/DWGSIM/dwgsim'
DWGSIM_CMD_FORMAT = ' -r %f -e %f -1 %d -2 0 -y 0 %s %s'
OUTPUT_NAME = 'reads'

BWA_PATH = './full_validation_utilities/bwa'
BWA_INDEX_CMD_FORMAT = ' index %s'

NORM_PATH = './full_validation_utilities/vcf_tools/vt/vt'
NORM_CMD_FORMAT = ' normalize -o %s -r %s %s'

BWA_CMD_FORMAT = ' mem -x ont2d %s %s > %s'
OUTPUT_BWA_NAME = 'deleteme'

ALIGNER_PATH = './auto_read_aligner.py'
simFilesToRemove = [OUTPUT_NAME + '.bfast.fastq', OUTPUT_NAME + '.bwa.read2.fastq', OUTPUT_NAME + '.mutations.txt']

def stdPrint(txt):
	sys.stdout.write(txt + '\n')

def setUpBWA(referenceFilePath, currPath):
	os.system('cp ' + referenceFilePath + ' ' + currPath)
	os.system(BWA_PATH + BWA_INDEX_CMD_FORMAT % (currPath + referenceFilePath))

def dwgsimCommand(simParameters, referenceFilePath, currPath):
	readLen = simParameters['Read Length']
	seqErrorRate = simParameters['Sequencing Error Rate']
	mutRate = simParameters['Mutation Rate']
	return DWGSIM_CMD_FORMAT % (mutRate, seqErrorRate, readLen, referenceFilePath, currPath + OUTPUT_NAME)

def bwaCommand(referenceFilePath, readsFilePath, outputPath):
	bwaCmd = BWA_PATH + BWA_CMD_FORMAT % (referenceFilePath, readsFilePath, outputPath + OUTPUT_BWA_NAME)
	return bwaCmd

def normalize(referenceFilePath, mutFilePath, mutNormalizedFilePath):
	normalizeCmd = NORM_PATH + NORM_CMD_FORMAT % (mutNormalizedFilePath, referenceFilePath, mutFilePath)
	os.system(normalizeCmd)

def alignAndGenSAMvcf(referenceFilePath, readsFilePath, currPath, mutNormalizedFilePath):
	#Generate vcf
	os.system('python ' + ALIGNER_PATH + ' %s %s %s %s' % (referenceFilePath, readsFilePath, currPath, currPath + 'reads.mutations.sam.vcf'))

	#Generate normalized vcf
	normalize(referenceFilePath, currPath + 'reads.mutations.sam.vcf', mutNormalizedFilePath)


def removeUnnecessarySimFiles(basePath):
	for file in simFilesToRemove:
		os.system('rm ' + basePath + file)

def removeUnnecessaryBwaFiles(basePath):
	os.system('rm ' + basePath + OUTPUT_BWA_NAME)

def performBWA(referenceFilePath, currPath, simParameters):
	readMeFilePath = currPath + 'README.dig'
	os.system('{ time ' + bwaCommand(referenceFilePath, currPath + 'reads.fq', currPath) + ' ; } 2>' + readMeFilePath)
	
	#Remove the junk from the top of the file
	simInfo = ''
	with open(readMeFilePath, 'r') as readMeFile:
		for line in readMeFile.readlines():
			line = line.strip('\n')
			if len(line) > 0 and line[0] != '[' and 'user' not in line and 'sys' not in line:
				simInfo += line + '\n'
	with open(readMeFilePath, 'w') as readMeFile:
		for key in sorted(simParameters.keys()):
			simInfo += key + '\t' + str(simParameters[key]) + '\n'
		readMeFile.write(simInfo)

def performSIM(path, referenceFilePath, simParameters):
	stdPrint('		Perform SIM: Simulating for' + str(simParameters))
	os.system(DWGSIM_PATH + dwgsimCommand(simParameters, referenceFilePath, path))
	stdPrint('		Perform SIM: Simulating Finished')

	stdPrint('		Perform SIM: Adjust reads file name')
	os.system('mv ' + path + 'reads.bwa.read1.fastq ' + path + 'reads.fq')

	stdPrint('		Perform SIM: Start normalizing')
	normalize(referenceFilePath, path + 'reads.mutations.vcf', path + 'reads.mutations.normalized.dwg.vcf')
	stdPrint('		Perform SIM: Finish normalizing')

	stdPrint('		Perform SIM: Start generating VCF from SAM')
	alignAndGenSAMvcf(referenceFilePath, path + 'reads.fq', path, path + 'reads.mutations.normalized.sam.vcf')
	stdPrint('		Perform SIM: Finished generating VCF from SAM')

	stdPrint('		Perform SIM: Start removing unnecessary simulation files')
	removeUnnecessarySimFiles(path)
	stdPrint('		Perform SIM: Finished removing unnecessary simulation files')

	stdPrint('		Perform BWA: Start aligning')
	performBWA(referenceFilePath, path, simParameters)
	stdPrint('		Perform BWA: Finished aligning')
	
	stdPrint('		Perform BWA: Start removing unnecessary bwa files')
	removeUnnecessaryBwaFiles(path)
	stdPrint('		Perform BWA: Finished removing unnecessary bwa files')
