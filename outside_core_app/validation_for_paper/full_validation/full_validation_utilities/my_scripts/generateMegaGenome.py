from sys import argv

def createMegaGenome(genomes):
	contents = {}
	for fileName in genomes:
		with open(fileName, 'r') as file:
			contents[fileName.replace('.fa', '').replace('.fasta', '')] = file.read()
	for name in contents:
		genome = contents[name]
		conciseName = name[name.rfind('/') + 1 :]
		firstSpaceInGenome = genome.find(' ')
		if genome[firstSpaceInGenome - 1] == '|':
			genome = genome.replace(' ', conciseName.replace('flu.', '') + ' ', 1)
		else:
			genome = genome.replace(' ', conciseName.replace('flu.', '|') + ' ', 1)

		if genome[len(genome) - 1] != '\n':
			genome += '\n'
		contents[name] = genome
	result = "".join(genome for genome in contents.values());
	return result

def main():
	if (len(argv) < 3):
		print 'genome1 genome2 genome3 mega_genome_name'
		return
	else:
		megaGenome = createMegaGenome(argv[1:len(argv) - 1])
		with open(argv[len(argv) - 1], 'w') as file:
			file.write(megaGenome)


if __name__ == "__main__":
	main()