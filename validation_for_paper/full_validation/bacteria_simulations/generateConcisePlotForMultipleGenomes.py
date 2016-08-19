from sys import argv
import os
import matplotlib.pyplot as plt
import json

LINE_WIDTH = 3
GEN_CONCISE_REPORT_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/bacteria_simulations/generateConciseReportFilesForMultipleGenomes.py'

currPath = os.path.abspath(argv[1])
dwgPath = os.path.abspath(argv[2]) #Should be the path to the directory containing all the gen output folders
igPath = os.path.abspath(argv[3]) #Should be the path to the directory containing the tree of iGenomics output folders

conciseReportFilePath = os.path.join(currPath, 'concise_report.cpr')
os.system('python ' + GEN_CONCISE_REPORT_PATH + ' ' + currPath + ' ' + dwgPath + ' ' + igPath + ' > ' + conciseReportFilePath)

dataPoints = []
with open(conciseReportFilePath) as conciseFile:
	for line in conciseFile.readlines():
		line = line.strip('\n').strip('\r')
		info = json.loads(line)
		dataPoints.append(info)

plotDataPoints = {}
for data in dataPoints:
	for runtimeKey in data['runtimes']:
		if runtimeKey not in plotDataPoints:
			plotDataPoints[runtimeKey] = {}
		readLen = data['read len']
		if readLen not in plotDataPoints[runtimeKey]:
			plotDataPoints[runtimeKey][readLen] = []
		plotDataPoints[runtimeKey][readLen].append(
			{'runtime': data['runtimes'][runtimeKey],
			'reference length': data['reference length']
			})

# print plotDataPoints
plotPath = os.path.join(currPath, 'concise_plot.pdf')

cm = plt.get_cmap('rainbow')
NUM_COLORS = 4

plt.axes().set_color_cycle([cm(1.*i/NUM_COLORS) for i in range(NUM_COLORS)])
plt.title('Runtime vs. Reference Length')
plt.xlabel('Reference Length (bp)')
plt.ylabel('Runtime (s)')

# #a) Plot iGenomics runtime
colorsForVerticalLines = ['red', 'orange', 'green', 'blue', 'indigo']
labelsForVerticalLines = ['PhiX174 (5386bp)', 'Zika (10807bp)', 'H1N1 (13382bp)', 'H3N2 (13568bp)', 'Ebola (18957bp)']
refLinesAlreadyShowing = False
for runtimeKey in plotDataPoints:
	for readLen in plotDataPoints[runtimeKey]:
		plotDataPt = plotDataPoints[runtimeKey][readLen]
		sortedPlotDataPt = sorted(plotDataPt, key=lambda x: x['reference length'])
		refLens = [singlePt['reference length'] for singlePt in sortedPlotDataPt]
		if refLinesAlreadyShowing == False:
			for i, refLen in enumerate(refLens):
				plt.axvline(refLen, color=colorsForVerticalLines[i], linestyle='dashed', label=labelsForVerticalLines[i])
			refLinesAlreadyShowing = True
		runtimes = [singlePt['runtime'] for singlePt in sortedPlotDataPt] 
		print sortedPlotDataPt
		label = runtimeKey + ' | ' + str(readLen) + 'bp'
		plt.plot(refLens, runtimes, label=label, linewidth=LINE_WIDTH)

plt.legend(loc=0,prop={'size':6})
plt.savefig(plotPath)
plt.gcf().clear()




