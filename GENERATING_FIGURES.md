# iGenomics Script Explanations
## Figure 1
### Screenshots of iGenomics
Take screenshots of iGenomics after aligning a set of simulated H1N1 reads to a reference genome

## Figure 2
### Bacteria Runtime Comparison
For each bacteria reference genome, a set of reads was simulated, aligned against the reference genome, and then had variants identified. Specifically:

The iGenomics script responsible for this is `auto_read_generation.py` (located at `/outside_core_app/validation_for_paper/full_validation/auto_read_generation.py`), which executes each of the following bash commands and places all final output files at a path that follows generation_output_<bacteria name>/read_len<read len>>bp/seq_error_rate<sequencing error rate>/mut_rate<mutation rate>/X:
- Simulate reads: `dwgsim  -r [rate of mutations] -e [per base/color/flow error rate of the first read] -1 [length of the first read] -2 [length of the second read] -y [probability of a random DNA read] [reference genome path] [output file path]`
- Normalize the simulated mutations: `vt normalize -o [normalized mutations output path] -r [reference genome path] [VCF file path]`
- Align simulated reads to the reference using bwa and identify variants and record the time to do so, following the commands in `auto_read_aligner.py`(located at `/outside_core_app/validation_for_paper/full_validation/auto_read_aligner.py`):
--- Align reads: `bwa mem -x ont2d [reference genome path] [reads path] > out.sam`
--- Convert SAM alignments to BAM: `samtools view -bT [reference genome path] out.sam > out.bam`
--- Sort alignments: `samtools sort out.bam -o out.sorted.bam`
--- Call variants from BAM: `samtools mpileup -uBQ0 -f [reference genome path] out.sorted.bam | bcftools call -mAv > calls.raw.bcf`
--- Generate VCF from BCF: `bcftools filter -s LowQual calls.raw.bcf > calls.raw.vcf`
- Normalize the mutations identified after aligning the simulated reads to the reference using bwa

Next, we generate a plot of bacteria reference length vs runtime using `generate_runtime_plot.py` (located at `/outside_core_app/validation_for_paper/full_validation/updated_runtime_simulations_2019/bacteria_simulations/generate_runtime_plot.py`). This script iterates through all the iGenomics and BWA runtime output files for each bacteria genome and generates a plot by adding a point for each iGenomics runtime and each BWA runtime.

## Figure 3
### Mutation identification accuracy for simulated H1N1 flu datasets of varying mutation rates and error rates for iGenomics and the BWA-MEM/Samtools  pipeline

For varying H1N1 reads simulated according to different parameters, the accuracy of iGenomics and BWA in identifying variants within the aligned reads was determined. 

The iGenomics script responsible for this is `auto_comparison.py`, which is located at `/outside_core_app/validation_for_paper/full_validation/auto_comparison.py`. This script performs the following analysis:
1. Takes as input all the BWA alignment and identified variant files, all the iGenomics alignment and identified variant files, and a parameters file detailing the conditions of the simulated reads (which varied in mutation rate, sequence error rate, and read length).
2. For each pair of iGenomics and BWA files, compare the alignment results with each other.
3. For each BWA+SAMtools variant output file, compare that with the results of DWGSIM for that particular simulated data set using `compare_mutations_vcfs` (located at `./outside_core_app/validation_for_paper/full_validation/full_validation_utilities/my_scripts/compare_mutations_vcfs.py`).
4. For each iGenomics variant output file, compare that with the results of DWGSIM for that particular simulated data set using `compare_mutations_vcfs.py`.

When the comparisons are completed, the following scripts can be run, which read the comparison output files and generate the plots shown in this fugure: `auto_plot_comparison_generation.py` for iGenomics (located at `/outside_core_app/validation_for_paper/full_validation/auto_plot_comparison_generation.py`) and `auto_plot_comparison_generation_sam.py` for SAM (located at `/outside_core_app/validation_for_paper/full_validation/auto_plot_comparison_generation_sam.py`).

## Figure 4
### iGenomics runtime vs. BWA/Samtools pipeline runtime for simulated datasets of constant mutation rates and sequence error rates of H1N1 for varying read lengths. 

Use the same method for simulating reads described earlier to simulate reads and align reads with BWA+SAMtools here. Since the data used to compute this figure is a subset of the data generated for Figure 3, that same data could be re-used to fulfill the requirement of BWA+SAMtools data needed in computing this figure. 

Then, to record the iGenomics runtimes, these simulated data sets are also aligned to the reference using iGenomics and the output alignments file, which contains the end-to-end alignment and variant identification runtime, is exported. Finally, the script `generate_runtime_plot.py` (located at `./outside_core_app/validation_for_paper/full_validation/updated_runtime_simulations_2019/H1N1_simulations/generate_runtime_plot.py`) is used to generate the runtime plot. In Figure 4, the BWA files used were from `./outside_core_app/validation_for_paper/full_validation/updated_runtime_simulations_2019/H1N1_simulations/bwa_files_2019` and the iGenomics files used were from `./outside_core_app/validation_for_paper/full_validation/updated_runtime_simulations_2019/H1N1_simulations/ig_files_2019`.

## Figure 5
### BWT construction
Performed by hand

## Figure 6
### Exact matching wit the BWT
Performed by hand

## Figure 7
### Edit distance computation
Performed by hand

## Figure 8
### Coverage Profile
Performed by hand

## Table 1
### iGenomics vs. BWA+SAMtools for Ebola and Zika MinION data and iGenomics vs. BWA+SAMtools for H3N2 MinION and MiSEQ MinION data

In order to compare iGenomics results (obtained by using iGenomics on an iOS device) with the alignment rate and variant calls of BWA+SAMtools for Ebola, Zika, and H3N2 (both MinION and MiSEQ), we use the script `performComparisons.py` (located at `/outside_core_app/validation_for_paper/full_validation/actual_data/performComparisons.py`). This script works by running `auto_read_aligner.py` (described in Figure 2) to obtain the BWA+SAMtools results and then running `vt normalize -r [reference genome path] -o [normalized mutations output path] [mutations path]` for both iGenomics and BWA+SAMtools mutations. Finally, `compare_mutations_vcfs.py` (described in Figure 3) is run to actually compare the mutations found by iGenomics with those found by BWA+SAMtools.

For comparing the iGenomics and BWA+SAMtools results with the Zika Nucmer calls, we simply skip the alignment step in `performComparisons.py` and compare each of iGenomics and BWA+SAMtools to the Nucmer calls following the same logic of normalizing all calls and then comparing the calls with `compare_mutations_vcfs.py`.


## Table 2
### iGenomics pan-genome analysis for MinION and Illumina simulated data

To perform this analysis, reads were simulated against the pan-genome in the same manner as described earlier (e.g., using DWGSIM). Then, the reads were aligned against the pan-genome using iGenomics and the alignment rate and runtime were calculated by iGenomics. To calculate the segment identification rate, the script `validateMegaFluAlignments_non_repeating.py` (located at `/outside_core_app/validation_for_paper/full_validation/mega_flu_genome/validateMegaFluAlignments_non_repeating.py`) is used.
