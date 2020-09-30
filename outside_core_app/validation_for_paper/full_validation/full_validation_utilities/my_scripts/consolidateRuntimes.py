from sys import argv
bwaRuntime = ''
iGRuntime = ''

with open(argv[1]) as bwaRuntimeFile:
	for line in bwaRuntimeFile.readlines():
		if 'real' in line:
			runtimeStr = line.split('\t')[1].strip('\n')
			runtimeComps = runtimeStr.split('m')
			minutes = int(runtimeComps[0])
			seconds = float(runtimeComps[1].strip('s'))
			bwaRuntime = str(minutes * 60 + seconds)
			break

with open(argv[2]) as iGRuntimeFile:
	for line in iGRuntimeFile.readlines():
		if 'real' in line:
			iGRuntime = line.split('\t')[1].strip('\n')
			break

with open(argv[3], 'w') as runtimeFile:
	runtimeFile.write('iG\t' + iGRuntime + '\nBWA\t' + bwaRuntime)