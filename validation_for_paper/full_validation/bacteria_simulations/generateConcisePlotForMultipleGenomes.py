from sys import argv
import os
import matplotlib.pyplot as plt
import json

GEN_CONCISE_REPORT_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/bacteria_simulations/generateConciseReportFilesForMultipleGenomes.py'

currPath = os.path.abspath(argv[1])
dwgPath = os.path.abspath(argv[2]) #Should be the path to the directory containing all the gen output folders
igPath = os.path.abspath(argv[3]) #Should be the path to the directory containing the tree of iGenomics output folders

conciseReportFilePath = os.path.join(currPath, 'concise_report.cpr')
os.system('python ' + GEN_CONCISE_REPORT_PATH + ' ' + currPath + ' ' + dwgPath + ' ' + igPath + ' > ' + conciseReportFilePath)

data = []
with open(conciseReportFilePath) as conciseFile:
	for line in conciseFile.readlines():
		line = line.strip('\n').strip('\r')
		info = json.dumps(line)
		data.append(info)

plotPath = os.path.join(currPath, 'concise_plot.pdf')

cm = plt.get_cmap('rainbow')
NUM_COLORS = len(plotDataPoints)

plt.axes().set_color_cycle([cm(1.*i/NUM_COLORS) for i in range(NUM_COLORS)])
plt.title('Runtime vs. Reference Length')
plt.xlabel('Reference Length')
plt.ylabel('Runtime')




