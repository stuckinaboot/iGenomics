iGenomics
=========

Following the miniaturization of integrated circuitry and other computer hardware over the past several decades, DNA sequencing is following a similar path. Leading this trend is the Oxford Nanopore sequencing platform, which currently offers the hand-held MinION instrument and even smaller instruments on the horizon. This technology has been used in several important applications, including the analysis of genomes of major pathogens in remote stations around the world. However, despite the simplicity of the sequencer, an equally simple and portable analysis platform is not yet available.

iGenomics is the first comprehensive mobile genome analysis application, with capabilities to align reads, call variants, and visualize the results entirely on an iOS device. Implemented in Objective-C using the FM-index, banded dynamic programming, and other high-performance bioinformatics techniques, iGenomics is optimized to run in a mobile environment. We benchmark iGenomics using a variety of real and simulated Nanopore sequencing datasets of viral and bacterial genomes and show that iGenomics has performance comparable to the popular BWA-MEM/Samtools/IGV suite, without needing a laptop or server cluster. iGenomics is available for free on [Apple’s App Store](https://apple.co/2HCplzr). We also have a [tutorial available](http://schatz-lab.org/iGenomics/)

## Compilation Installation
1) Clone iGenomics repo
```
git clone https://github.com/stuckinaboot/iGenomics.git
```
2) `cd iGenomics`
3) Install cocoapods dependency manager
```
$ gem install cocoapods
```
4) Install pods (dependencies)
```
$ pod install
```
5) Open iGenomics.xcworkspace
6) Run iGenomics in Xcode

*I wrote the core of much of this code (and created what became this repo) when I was 14-16 years old, with no formal computer science training. Improving the code quality and file organization is certainly a worthy future task*
