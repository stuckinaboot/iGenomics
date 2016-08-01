from sys import argv
import os

autoReadGenPath = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/auto_read_generation.py'
makeSimulatedFileNamesMoreSpecificPath = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/bacteria_simulations/makeSimulatedFileNamesMoreSpecific.py'

if len(argv) > 2:
	paramFile = argv[1]
	fileNames = argv[2:]
	for fileName in fileNames:
		genome = fileName[: fileName.find('.fa')]
		os.system('python ' + autoReadGenPath + ' ' + paramFile + ' ' + fileName + ' _' + genome)
		os.system('python ' + makeSimulatedFileNamesMoreSpecificPath + ' simulated_reads_files' + '_' + genome + '/ ' + genome)
		os.system('ls')