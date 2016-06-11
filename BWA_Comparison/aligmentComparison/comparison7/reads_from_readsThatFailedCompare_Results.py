from sys import argv
failedFile = open(argv[1])
readsFile = open(argv[2])

readsNameList = []
for line in failedFile.readlines():
    comp = line.split(' ')
    readsNameList.append(comp[1])

readsDict = {}
i = 0
readName = ""
for line in readsFile.readlines():
	if i % 2 == 0:
		comp = line.split(' ')
		readName = comp[0][1:]
	else:
		readsDict[readName] = line.replace('\n', "")
	i += 1

finalReadsList = []
output = ""
for readName in readsNameList:
	if readName in readsDict:
		output += readName + '\n' + readsDict[readName] + '\n'

outFile = open('readsThatFailedCompareResults.fa', 'w')
outFile.write(output)
outFile.close()



