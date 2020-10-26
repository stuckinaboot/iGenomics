from sys import argv
import sys
import os
from os import listdir
from os.path import isfile, join
import matplotlib.pyplot as plt
import re
import json

LINE_WIDTH = 3

comparisonRoot = argv[1]
outputDir = os.path.abspath(argv[2])


def stdPrint(txt):
    sys.stdout.write(txt)


def extractParameters(fileName):
    components = fileName.split("/")
    parameters = {}
    for component in components:
        match = re.search("([a-z_]+)(\d+\.?\d+)", component)
        if match:
            parameters[match.group(1)] = match.group(2)
    return parameters


def extractRecall(file):
    lines = file.readlines()
    file.seek(0)
    return lines[3].split("\t")[0]


def extractPrecision(file):
    lines = file.readlines()
    file.seek(0)
    numPassing = int(lines[2].split("\t")[0])
    numFoundByiGLongStr = lines[4].split("\t")[0]
    numFoundByiG = numFoundByiGLongStr[(numFoundByiGLongStr.find(" ") + 1) :]
    return str(float(numPassing) / int(numFoundByiG))


def extractRuntimes(file):
    runtimes = {}
    for line in file.readlines():
        comps = line.split("\t")
        runtimes[comps[0]] = comps[1]
    file.seek(0)
    return runtimes


# http://stackoverflow.com/questions/2186525/use-a-glob-to-find-files-recursively-in-python

# 1) Obtain all files
allFiles = []
for root, dirs, files in os.walk(comparisonRoot):
    for file in files:
        if file.endswith(".fin"):
            allFiles.append(os.path.join(root, file))

# 2) Process all files to obtain dataPoints
dataPoints = []
for fileName in allFiles:
    if "validation.fin" in fileName:
        with open(fileName) as file:
            parameters = extractParameters(fileName)

            passRate = extractRecall(file)
            parameters["recall"] = passRate

            precisionRate = extractPrecision(file)
            parameters["precision"] = precisionRate

            runtimes = {}
            with open(
                fileName.replace("validation.fin", "runtimes.rt")
            ) as runtimesFile:
                runtimes = extractRuntimes(runtimesFile)

            parameters["runtime"] = runtimes

            dataPoints.append(parameters)

# 3) Convert the dataPoints into something usable for the plot
# a) vs read len
plotDataPoints = []
for dataPoint in dataPoints:
    data = {
        "seq_error_rate": dataPoint["seq_error_rate"],
        "mut_rate": dataPoint["mut_rate"],
    }

    dataSet = False
    for plotDataPoint in plotDataPoints:
        if data.items() <= plotDataPoint.items():
            data = plotDataPoint
            dataSet = True
            break

    if dataSet == False:
        plotDataPoints.append(data)
        data["recalls"] = {}
        data["precisions"] = {}
        data["f-scores"] = {}
        data["runtimes"] = {}

    data["recalls"][dataPoint["read_len"]] = dataPoint["recall"]
    data["precisions"][dataPoint["read_len"]] = dataPoint["precision"]
    fScore = (2 * float(dataPoint["recall"]) * float(dataPoint["precision"])) / (
        float(dataPoint["recall"]) + float(dataPoint["precision"])
    )
    data["f-scores"][dataPoint["read_len"]] = fScore
    data["runtimes"][dataPoint["read_len"]] = dataPoint["runtime"]

# Sort the following keys in each elt of plotDataPoints
# by read length: precisions, recalls, f-scores, runtimes
for plotDataPoint in plotDataPoints:
    plotDataPoint["recalls"] = {
        k: v
        for (k, v) in sorted(
            # Convert each key (read length) to a float for sorting
            # as they are stored as string initially
            # https://stackoverflow.com/questions/17474211/how-to-sort-python-list-of-strings-of-numbers
            plotDataPoint["recalls"].items(),
            key=lambda x: float(x[0]),
        )
    }
    plotDataPoint["precisions"] = {
        k: v
        for (k, v) in sorted(
            plotDataPoint["precisions"].items(), key=lambda x: float(x[0])
        )
    }
    plotDataPoint["f-scores"] = {
        k: v
        for (k, v) in sorted(
            plotDataPoint["f-scores"].items(), key=lambda x: float(x[0])
        )
    }
    plotDataPoint["runtimes"] = {
        k: v
        for (k, v) in sorted(
            plotDataPoint["runtimes"].items(), key=lambda x: float(x[0])
        )
    }

# b) vs seq error rate
plotDataPointsVSeqErrorRate = []
for dataPoint in dataPoints:
    data = {"read_len": dataPoint["read_len"], "mut_rate": dataPoint["mut_rate"]}

    dataSet = False
    for plotDataPoint in plotDataPointsVSeqErrorRate:
        if data.items() <= plotDataPoint.items():
            data = plotDataPoint
            dataSet = True
            break

    if dataSet == False:
        plotDataPointsVSeqErrorRate.append(data)
        data["recalls"] = {}
        data["precisions"] = {}
        data["f-scores"] = {}
        data["runtimes"] = {}

    data["recalls"][dataPoint["seq_error_rate"]] = dataPoint["recall"]
    data["precisions"][dataPoint["seq_error_rate"]] = dataPoint["precision"]
    fScore = (2 * float(dataPoint["recall"]) * float(dataPoint["precision"])) / (
        float(dataPoint["recall"]) + float(dataPoint["precision"])
    )
    data["f-scores"][dataPoint["seq_error_rate"]] = fScore
    data["runtimes"][dataPoint["seq_error_rate"]] = dataPoint["runtime"]
# 4) Generate plot

SHOW_LEGEND = True 

# a) Recall Plot
cm = plt.get_cmap("rainbow")
NUM_COLORS = len(plotDataPoints)

plt.axes().set_prop_cycle(color=[cm(1.0 * i / NUM_COLORS) for i in range(NUM_COLORS)])
plt.title("Mutation Recall vs. Read Length")
plt.xlabel("Read Length (bp)")
plt.ylabel("Recall")

for plotDataPoint in plotDataPoints:
    recallsDict = plotDataPoint["recalls"]
    readLens = []
    recalls = []
    for readLen in recallsDict:
        readLens.append(int(readLen))
        recalls.append(float(recallsDict[readLen]))
    label = (
        plotDataPoint["seq_error_rate"]
        + " seq err rate | "
        + plotDataPoint["mut_rate"]
        + " mut rate"
    )
    stdPrint("Read Lens: " + json.dumps(readLens) + "\n")
    stdPrint("Recalls: " + json.dumps(recalls) + "\n")
    stdPrint("label: " + label + "\n\n")
    plt.plot(readLens, recalls, label=label, linewidth=LINE_WIDTH)
if SHOW_LEGEND:
    plt.legend(loc=0, prop={"size": 6})
plt.savefig(os.path.join(outputDir, "auto_plot_output.recall.pdf"))
plt.gcf().clear()

# b) Precision Plot
plt.axes().set_prop_cycle(color=[cm(1.0 * i / NUM_COLORS) for i in range(NUM_COLORS)])
plt.title("Mutation Precision vs. Read Length")
plt.xlabel("Read Length (bp)")
plt.ylabel("Precision")

for plotDataPoint in plotDataPoints:
    precisionsDict = plotDataPoint["precisions"]
    readLens = []
    precisions = []
    for readLen in precisionsDict:
        readLens.append(int(readLen))
        precisions.append(float(precisionsDict[readLen]))
    label = (
        plotDataPoint["seq_error_rate"]
        + " seq err rate | "
        + plotDataPoint["mut_rate"]
        + " mut rate"
    )
    stdPrint("Read Lens: " + json.dumps(readLens) + "\n")
    stdPrint("Precisions: " + json.dumps(precisions) + "\n")
    stdPrint("label: " + label + "\n\n")
    plt.plot(readLens, precisions, label=label, linewidth=LINE_WIDTH)
if SHOW_LEGEND:
    plt.legend(loc=0, prop={"size": 6})
plt.savefig(os.path.join(outputDir, "auto_plot_output.precision.pdf"))
plt.gcf().clear()

# c) F-Score vs. Read Len
plt.axes().set_prop_cycle(color=[cm(1.0 * i / NUM_COLORS) for i in range(NUM_COLORS)])
plt.title("Mutation F-Score vs. Read Length")
plt.xlabel("Read Length (bp)")
plt.ylabel("F-Score")

for plotDataPoint in plotDataPoints:
    fScoresDict = plotDataPoint["f-scores"]
    readLens = []
    fScores = []
    for readLen in fScoresDict:
        readLens.append(int(readLen))
        fScores.append(float(fScoresDict[readLen]))
    label = (
        plotDataPoint["seq_error_rate"]
        + " seq err rate | "
        + plotDataPoint["mut_rate"]
        + " mut rate"
    )
    stdPrint("Read Lens: " + json.dumps(readLens) + "\n")
    stdPrint("F-Scores: " + json.dumps(fScores) + "\n")
    stdPrint("label: " + label + "\n\n")
    plt.plot(readLens, fScores, label=label, linewidth=LINE_WIDTH)
if SHOW_LEGEND:
    plt.legend(loc=0, prop={"size": 6})
plt.savefig(os.path.join(outputDir, "auto_plot_output.fscore.vreadlen.pdf"))
plt.gcf().clear()

# d) F-Score vs. Seq Error Rate
plt.axes().set_prop_cycle(color=[cm(1.0 * i / NUM_COLORS) for i in range(NUM_COLORS)])
plt.title("Mutation F-Score vs. Seq Error Rate")
plt.xlabel("Error Rate")
plt.ylabel("F-Score")

for plotDataPoint in plotDataPointsVSeqErrorRate:
    fScoresDict = plotDataPoint["f-scores"]
    seqErrorRates = []
    fScores = []
    for errorRate in sorted(fScoresDict):
        seqErrorRates.append(float(errorRate))
        fScores.append(float(fScoresDict[errorRate]))
    label = (
        plotDataPoint["read_len"] + " bp | " + plotDataPoint["mut_rate"] + " mut rate"
    )
    stdPrint("Seq Err Rates: " + json.dumps(seqErrorRates) + "\n")
    stdPrint("F-Scores: " + json.dumps(fScores) + "\n")
    stdPrint("label: " + label + "\n\n")
    plt.plot(seqErrorRates, fScores, label=label, linewidth=LINE_WIDTH)
if SHOW_LEGEND:
    plt.legend(loc=0, prop={"size": 6})
plt.savefig(os.path.join(outputDir, "auto_plot_output.fscore.vseqerrorrate.pdf"))
plt.gcf().clear()


