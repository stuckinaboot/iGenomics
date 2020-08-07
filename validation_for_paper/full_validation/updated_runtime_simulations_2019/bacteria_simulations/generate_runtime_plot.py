from sys import argv
import matplotlib.pyplot as plt
import os
import json

if len(argv) == 1:
    print("args: CURR_PATH BWA_FILES_PATH IG_FILES_PATH")
    quit()

# print plot_data_points
CURR_PATH = os.path.abspath(argv[1])
BWA_FILES_PATH = os.path.abspath(argv[2])
IG_FILES_PATH = os.path.abspath(argv[3])
PLOT_PATH = os.path.join(CURR_PATH, "concise_bacteria_runtime_plot.pdf")

cm = plt.get_cmap("rainbow")
NUM_COLORS = 4

plt.axes().set_prop_cycle(color=[cm(1.0 * i / NUM_COLORS) for i in range(NUM_COLORS)])
plt.title("Runtime vs. Reference Length")
plt.xlabel("Reference Length (bp)")
plt.ylabel("Runtime (s)")

LINE_WIDTH = 3


def runtimeFromREADMEdig(readmeDigPath):
    with open(readmeDigPath) as file:
        runtime_line = file.readline()
        runtime_str = runtime_line.split("\t")[1].strip("s\n")
        runtime_components = runtime_str.split("m")
        actual_runtime = int(runtime_components[0]) * 60.0 + float(
            runtime_components[1]
        )
        return actual_runtime


# Fill plot_data_points
genome_lengths = {
    "phix174": 5386,
    "zika": 10807,
    "H1N1": 13568,
    "H3N2": 13382,
    "ebola": 18957,
}


def listdir_nohidden(path):
    for f in os.listdir(path):
        if not f.startswith("."):
            yield f


# For given analysis runner, for given bp length
# get points of that bp length and analysis runner for each bacteria
plot_data_points = {"bwa": {}, "iG": {}}


def get_runtimes(root_path, section):
    # In section
    # For given bp length, pts = []
    # For each bacteria, pts.append(runtime) where runtime
    # is runtime for that bacteria/bp len/bwa combo
    runtimes = {}
    for bacteria in listdir_nohidden(root_path):
        path = root_path + "/" + bacteria
        if os.path.isfile(path):
            continue
        for bplen in listdir_nohidden(path):
            path = root_path + "/" + bacteria + "/" + bplen
            if bplen not in runtimes:
                runtimes[bplen] = []
            for seq_err_rate in listdir_nohidden(path):
                path = root_path + "/" + bacteria + "/" + bplen + "/" + seq_err_rate
                for mut_rate in listdir_nohidden(path):
                    path = (
                        root_path
                        + "/"
                        + bacteria
                        + "/"
                        + bplen
                        + "/"
                        + seq_err_rate
                        + "/"
                        + mut_rate
                    )
                    runtime = runtimeFromREADMEdig(path + "/README.dig")
                    runtimes[bplen].append({"runtime": runtime, "bacteria": bacteria})
    return runtimes


plot_data_points["bwa"] = get_runtimes(BWA_FILES_PATH, "bwa")
plot_data_points["iG"] = get_runtimes(IG_FILES_PATH, "iG")

# Draw a single vertical line for each reference length

# a) Plot bwa runtime
COLORS_FOR_VERTICAL_LINES = ["red", "orange", "green", "blue", "indigo"]
LABELS_FOR_VERTICAL_LINES = [
    "PhiX174 (5386bp)",
    "Zika (10807bp)",
    "H3N2 (13382bp)",
    "H1N1 (13568bp)",
    "Ebola (18957bp)",
]
ref_lines_already_showing = False
sorted_genome_lengths = sorted(list(genome_lengths.values()))
for analysis_tool in plot_data_points:
    for readLen in plot_data_points[analysis_tool]:
        plotDataPt = plot_data_points[analysis_tool][readLen]
        sortedPlotDataPt = sorted(
            plotDataPt, key=lambda x: genome_lengths[x["bacteria"]]
        )
        # refLens = [singlePt['reference length'] for singlePt in sortedPlotDataPt]
        if ref_lines_already_showing == False:
            for i, ref in enumerate(genome_lengths):
                plt.axvline(
                    genome_lengths[ref],
                    color=COLORS_FOR_VERTICAL_LINES[i],
                    linestyle="dashed",
                    label=LABELS_FOR_VERTICAL_LINES[i],
                )
            ref_lines_already_showing = True
        runtimes = [singlePt["runtime"] for singlePt in sortedPlotDataPt]
        label = analysis_tool + " | " + str(readLen)
        # print(sortedPlotDataPt)
        # print(runtimes)
        # print(sorted_genome_lengths)
        # print('----------------------------')
        plt.plot(sorted_genome_lengths, runtimes, label=label, linewidth=LINE_WIDTH)

plt.legend(loc=0, prop={"size": 8})
plt.savefig(PLOT_PATH)
plt.gcf().clear()


# COLORS_FOR_VERTICAL_LINES = ['red', 'orange', 'green', 'blue', 'indigo']
# LABELS_FOR_VERTICAL_LINES = ['PhiX174 (5386bp)', 'Zika (10807bp)', 'H1N1 (13382bp)', 'H3N2 (13568bp)', 'Ebola (18957bp)']
# ref_lines_already_showing = False
# for runtimeKey in plot_data_points:
#     for readLen in plot_data_points[runtimeKey]:
#         plotDataPt = plot_data_points[runtimeKey][readLen]
#         sortedPlotDataPt = sorted(plotDataPt, key=lambda x: x['reference length'])
#         refLens = [singlePt['reference length'] for singlePt in sortedPlotDataPt]
#         if ref_lines_already_showing == False:
#             for i, refLen in enumerate(refLens):
#                 plt.axvline(refLen, color=COLORS_FOR_VERTICAL_LINES[i], linestyle='dashed', label=LABELS_FOR_VERTICAL_LINES[i])
#             ref_lines_already_showing = True
#         runtimes = [singlePt['runtime'] for singlePt in sortedPlotDataPt]
#         print sortedPlotDataPt
#         label = runtimeKey + ' | ' + str(readLen) + 'bp'
#         plt.plot(refLens, runtimes, label=label, linewidth=LINE_WIDTH)

# plt.legend(loc=0,prop={'size':6})
# plt.savefig(PLOT_PATH)
# plt.gcf().clear()

