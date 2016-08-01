from sys import argv
import os

if (len(argv) == 1):
	print 'ref reads currPath vcfOut\n\n\n\n'

ref = argv[1]
reads = os.path.abspath(argv[2])
currPath = os.path.abspath(argv[3]) + '/'
currPath = currPath.replace('//', '/')
vcfOut = argv[4]

BWA_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/bwa'
BWA_CMD = BWA_PATH + ' mem -x ont2d {0} {1} > {2}out.sam'.format(ref, reads, currPath)

SAMTOOLS_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/samtools-1.3.1/samtools'

SAM_TO_BAM_CMD = SAMTOOLS_PATH + ' view -bT {0} {1}out.sam > {1}out.bam'.format(ref, currPath)

BAM_TO_SORTED_BAM_CMD = SAMTOOLS_PATH + ' sort {0}out.bam -o {0}out.sorted.bam'.format(currPath)

BCFTOOLS_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/bcftools-1.3.1/bcftools'
VCFTOOLS_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/full_validation_utilities/bcftools-1.3.1/vcfutils.pl'

#GEN_VCF_CMD = SAMTOOLS_PATH + ' mpileup -uf {0} {1}out.sorted.bam | {2} call -mv -Ov > {1}{3}'.format(ref, currPath, BCFTOOLS_PATH, vcfOut )
GEN_BCF_CMD = SAMTOOLS_PATH + ' mpileup -uBQ0 -f {0} {1}out.sorted.bam | {2} call -mAv > {1}{3}'.format(ref, currPath, BCFTOOLS_PATH, 'calls.raw.bcf' )
FILTER_BCF_CMD = BCFTOOLS_PATH + ' filter -s LowQual {0}calls.raw.bcf > {1}'.format(currPath, vcfOut)
# BCF_TO_VCF_CMD = BCFTOOLS_PATH + ' view var.raw.bcf | {0} varFilter > var.flt.vcf '.format(VCFTOOLS_PATH)

cmds = [BWA_CMD, SAM_TO_BAM_CMD, BAM_TO_SORTED_BAM_CMD, GEN_BCF_CMD, FILTER_BCF_CMD]

for cmd in cmds:
	os.system(cmd)
	
print 'Removing no-longer needed files'
# os.system('rm {0}*.bam'.format(currPath))
print 'Auto Read Alignment Finished'