'''
|Algorithm|
____________________________________________________________________________________________________
----|Read in parameters file
----|Read in reference file
----|Generate folder subtree: 
    ----|For each read length, create a read length folder:
        ----|For each read length folder that just gets created, create a sequence error rate folder:
            ----|For each sequence error rate folder that just gets created, create a mutation rate folder:
                ----|For each mutation rate folder that just gets created, perform SIM on that folder with the parameters determined by its path to the root:
                    ----|Output generation for parameters ... (simulation i)  completed
____________________________________________________________________________________________________
'''
import sys
import os
import auto_read_simulation
from sys import argv

READ_LEN_PARAM = 'Read Length'
SEQ_ERR_RATE_PARAM = 'Sequencing Error Rate'
MUT_RATE_PARAM = 'Mutation Rate'
NECESSARY_KEYS_IN_PARAM = [READ_LEN_PARAM, SEQ_ERR_RATE_PARAM, MUT_RATE_PARAM]

def parametersDictFromParametersFile(file):
	parameters = {}
	for line in file.readlines():
		line = line.strip('\n')
		components = line.split('\t')
		parameters[components[0]] = []
		for i in range(1, len(components)):
			parameters[components[0]].append(float(components[i]))
	return parameters

def stdPrint(txt):
	sys.stdout.write(txt + '\n')

def printDivider():
	stdPrint('____________________________________________________________________________________________________')

def createDirectoryAtPath(path):
    try:
        os.makedirs(path)
        stdPrint('	Create Directory At Path: Dir created - ' + path)
    except:
    	stdPrint('	Create Directory At Path: Already exists - ' + path)

def runSIM(path, referenceFile, simParameters):
	auto_read_simulation.performSIM(path, referenceFile.name, simParameters)

def createDirectorySubtree(parameters, referenceFile):
	for key in NECESSARY_KEYS_IN_PARAM:
		if key not in parameters:
			stdPrint('Create Directory Subtree: Parameters check failed')
			return
	stdPrint('Create Directory Subtree: Parameters check passed')
	root = 'generation_output/'
	createDirectoryAtPath(root)

	bwaFilesPath = 'bwa_files/'
	createDirectoryAtPath(bwaFilesPath)

	readsFilesPath = 'simulated_reads_files/'
	createDirectoryAtPath(readsFilesPath)

	stdPrint('Create Directory Subtree: Setting up BWA Files')
	auto_read_simulation.setUpBWA(referenceFile.name, bwaFilesPath)
	stdPrint('Create Directory Subtree: Setting up BWA Files finished')
	refFileName = referenceFile.name
	referenceFile.close()
	referenceFile = open(bwaFilesPath + refFileName, 'r')

	for readLength in parameters[READ_LEN_PARAM]:
		readLength = int(readLength)

		#Create read length folder if one is not there
		readLenPath = root + 'read_len' + str(int(readLength)) + 'bp/'
		createDirectoryAtPath(readLenPath)
		for seqErrorRate in parameters[SEQ_ERR_RATE_PARAM]:
			#Create seq error rate folder within the read length folder if one is not there
			seqErrorPath = readLenPath + 'seq_error_rate' + str(seqErrorRate) + '/'
			createDirectoryAtPath(seqErrorPath)
			for mutRate in parameters[MUT_RATE_PARAM]:
				#Create mut error rate folder within the seq error rate folder if one is not there
				mutRatePath = seqErrorPath + 'mut_rate' + str(mutRate) + '/'
				createDirectoryAtPath(mutRatePath)
				simParameters = {'Read Length': readLength, 'Sequencing Error Rate': seqErrorRate, 'Mutation Rate': mutRate}
				runSIM(mutRatePath, referenceFile, simParameters)

				#Copy the generated reads file into the higher-level reads file folder
				readsFileNameInCopiedDir = 'reads-rl' + str(readLength) + '-se' + str(seqErrorRate) + '-mr' + str(mutRate) + '.fq'
				os.system('cp ' + mutRatePath + 'reads.fq ' + readsFilesPath + readsFileNameInCopiedDir)

def main():
	os.system('clear')
	stdPrint('Auto Read Generation: Generation Started')
	printDivider()

	parametersFile = open(argv[1], 'r')
	referenceFile = open(argv[2], 'r')

	stdPrint('Parameters: Reading Started')
	parameters = parametersDictFromParametersFile(parametersFile)
	stdPrint('Parameters: ' + str(parameters))
	stdPrint('Parameters: Reading Finished')

	printDivider()
	stdPrint('Create Directory Subtree: Creation Started')
	createDirectorySubtree(parameters, referenceFile)
	stdPrint('Create Directory Subtree: Creation Finished')

	printDivider()
	stdPrint('Auto Read Generation: Generation Finished')

if __name__ == "__main__":
	main()