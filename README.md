iGenomics 🧬
=========

Following the miniaturization of integrated circuitry and other computer hardware over the past several decades, DNA sequencing is following a similar path. Leading this trend is the Oxford Nanopore sequencing platform, which currently offers the hand-held MinION instrument and even smaller instruments on the horizon. This technology has been used in several important applications, including the analysis of genomes of major pathogens in remote stations around the world. However, despite the simplicity of the sequencer, an equally simple and portable analysis platform is not yet available.

iGenomics is the first comprehensive mobile genome analysis application, with capabilities to align reads, call variants, and visualize the results entirely on an iOS device. Implemented in Objective-C using the FM-index, banded dynamic programming, and other high-performance bioinformatics techniques, iGenomics is optimized to run in a mobile environment. We benchmark iGenomics using a variety of real and simulated Nanopore sequencing datasets of viral and bacterial genomes and show that iGenomics has performance comparable to the popular BWA-MEM/Samtools/IGV suite, without needing a laptop or server cluster. iGenomics is available for free on [Apple’s App Store](https://apple.co/2HCplzr). We also have a [tutorial available](http://schatz-lab.org/iGenomics/)

## Sponsors ❤️
[Icculus](https://icculus.org/microgrant2020/)

## Contributors 😎
[@stuckinaboot](https://github.com/stuckinaboot) [@mschatz](https://github.com/mschatz)

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

## Contributing 🚀

### Submitting Issues

If you notice any bugs, create a GitHub issue with the title being a very short summary of the problem, e.g. `Dropbox not showing file picker`, and the description being the _exact_ steps to reproduce the issue. If we do not have the _exact_ steps, we can't figure out what's wrong and can't fix it.

If you notice any room for improvement, create a GitHub issue with the title being a very short summary of the improvement, e.g. `Improve matcher code quality`, and the description being the improvement you would like to see made. Feel free to add hints on the approach you would take.

### Addressing Issues

Thank you for deciding to contribute! Pick a GitHub issue that you would like to address (or add your own), and then assign yourself to that issue. Then, fork the repo and add any changes you would like to make to that fork. When you would like to submit your changes for review, create a pull request, list the specific changes that you made, and I will review/test it myself as soon as possible. 

Note: the core alignment and mutations identification logic has been validated extensively against BWA-MEM/SAMtools alignments and mutations as well as against nucmer calls (where applicable). That said, I'm aware that the alignment and mutation identification code isn't the cleanest (I wrote the core of it when I was ~15) so feel free to submit improvements to that code but please be aware that pull requests related to that code could take a while to review/validate.


If you have any questions at all, please feel free to contact me on [linkedin](https://www.linkedin.com/in/aspyn-palatnick-577270131/) and I'll get back to you as soon as possible.

*I wrote the core of much of this code (and created what became this repo) when I was 14-16 years old, with no formal computer science training. Improving the code quality and file organization is certainly a worthy future task*
