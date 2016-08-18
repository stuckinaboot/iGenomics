from sys import argv
import os

AUTO_READ_ALIGNER_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/auto_read_aligner.py'
AUTO_READ_ALIGNER_CMD = '{0} {1} {2} {3}'

AUTO_NORMALIZE_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/vcf_tools/vt/vt'
AUTO_NORMALIZE_CMD = 'normalize -r {0} -o {1} {2}'

AUTO_COMPARE_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/my_scripts/compare_mutations_vcfs.py'
AUTO_COMPARE_CMD = '{0} {1}'

print 'ref path, reads file path, bwa directory, igenomics muts path, output path\n\n\n'

refFilePath = os.path.abspath(argv[1])
readsFilePath = os.path.abspath(argv[2])
bwaPath = os.path.abspath(argv[3])

igenomicsFilePath = os.path.abspath(argv[4])
outputPath = os.path.abspath(argv[5])

#Align reads
bwaMutsOutPath = os.path.join(bwaPath, 'mutations.bwa.vcf')

outputReadmePath = os.path.join(bwaPath, 'README.dig')
os.system('{ time' + ' python ' + AUTO_READ_ALIGNER_PATH + ' ' + AUTO_READ_ALIGNER_CMD.format(refFilePath, readsFilePath, bwaPath, bwaMutsOutPath) + '; } 2> ' + outputReadmePath)

# with open(outputReadmePath) as file:
# 	line = file.readline()
# 	print line
# 	time = float(line)

# with open(outputReadmePath, 'w') as file:
# 	file.write('real\t' + str(time))

#Normalize bwa mutations
bwaMutsNormalizedOutPath = os.path.join(outputPath, 'mutations.bwa.normalized.vcf')
os.system(AUTO_NORMALIZE_PATH + ' ' + AUTO_NORMALIZE_CMD.format(refFilePath, bwaMutsNormalizedOutPath, bwaMutsOutPath))

#Normalize iGenomics mutations
igenomicsMutsNormalizedOutPath = os.path.join(outputPath, 'mutations.ig.normalized.vcf')
os.system(AUTO_NORMALIZE_PATH + ' ' + AUTO_NORMALIZE_CMD.format(refFilePath, igenomicsMutsNormalizedOutPath, igenomicsFilePath))

#Compare iGenomics mutations to BWA mutations
mutationsOutPath = os.path.join(outputPath, 'mutations.out')
os.system('python ' + AUTO_COMPARE_PATH + ' ' + AUTO_COMPARE_CMD.format(bwaMutsNormalizedOutPath, igenomicsMutsNormalizedOutPath) + ' > ' + mutationsOutPath)

