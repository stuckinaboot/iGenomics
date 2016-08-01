from sys import argv
import os

for fileName in os.listdir(argv[1]):
	oldFilePath = os.path.join(argv[1], fileName)
	newFilePath = os.path.join(argv[1], argv[2] + '-' + fileName)
	os.system('mv ' + oldFilePath + ' ' + newFilePath)