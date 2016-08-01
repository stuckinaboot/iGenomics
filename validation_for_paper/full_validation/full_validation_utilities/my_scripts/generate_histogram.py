from sys import argv
import matplotlib.pyplot as plt
import re

#1) Gather data from input file
#Format for dict in mutData is {ref: , counts: {A: ..., C: ...}} 
mutData = []
with open(argv[1]) as file:
	for line in file.readlines():
		components = line.split('\t')
		ref = components[0]
		match = re.search('\[([\w-]+=\w+)\]\[([\w-]+=\w+)\]', components[1])
		counts = {}
		for group in match.groups():
			groupComponents = group.split('=')
			counts[groupComponents[0]] = groupComponents[1]
		mutData.append({'ref': ref, 'counts': counts})

#2) Process data so that something can be plotted. In this case, we will plot the relative frequency of the reference base
plotData = []
for mutDataObj in mutData:
	ref = mutDataObj['ref']
	total = 0
	for countKey in mutDataObj['counts']:
		total += int(mutDataObj['counts'][countKey])
	if ref in mutDataObj['counts']:
		plotData.append(float(mutDataObj['counts'][ref]) / total)
print(plotData)

#3) Generate plot
plt.title('Frequency vs. Relative Coverage')
plt.xlabel('Relative Coverage of Reference Base')
plt.ylabel('Frequency')

bins = []
currVal = 0
while currVal < 1:
	bins.append(currVal)
	currVal += .02

plt.hist(plotData, bins, histtype='bar')
plt.savefig('output.pdf')