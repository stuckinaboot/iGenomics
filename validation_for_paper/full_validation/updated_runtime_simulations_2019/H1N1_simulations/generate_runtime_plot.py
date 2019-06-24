from sys import argv
import matplotlib.pyplot as plt
import os
import json

if (len(argv) == 1):
    print('args: CURR_PATH BWA_FILES_PATH IG_FILES_PATH')
    quit()

# print plot_data_points
CURR_PATH = os.path.abspath(argv[1])
BWA_FILES_PATH = os.path.abspath(argv[2])
IG_FILES_PATH = os.path.abspath(argv[3])
PLOT_PATH = os.path.join(CURR_PATH, 'concise_h1n1_plot.pdf')

cm = plt.get_cmap('rainbow')
NUM_COLORS = 9

plt.axes().set_color_cycle([cm(1.*i/NUM_COLORS) for i in range(NUM_COLORS)])
plt.title('iGenomics Runtime vs. BWA Runtime')
plt.xlabel('BWA Runtime (s)')
plt.ylabel('iGenomics Runtime (s)')

LINE_WIDTH = 3

def runtimeFromREADMEdig(readmeDigPath):
    with open(readmeDigPath) as file:
        runtime_line = file.readline()
        runtime_str = runtime_line.split('\t')[1].strip('s\n')
        runtime_components = runtime_str.split('m')
        actual_runtime = int(runtime_components[0]) * 60.0 + float(runtime_components[1])
        return actual_runtime

def listdir_nohidden(path):
    for f in os.listdir(path):
        if not f.startswith('.'):
            yield f

# For given analysis runner, for given bp length
# get points of that bp length and analysis runner for each bacteria
plot_data_points = {'bwa': {}, 'iG': {}}

def get_runtimes(root_path, section):
    # In section
    # For given bp length, pts = []
    # For each bacteria, pts.append(runtime) where runtime 
    # is runtime for that bacteria/bp len/bwa combo
    runtimes = {}
    for bplen in listdir_nohidden(root_path):
        path = root_path + '/' + bplen
        for seq_err_rate in listdir_nohidden(path):
            path = root_path + '/' + bplen + '/' + seq_err_rate
            for mut_rate in listdir_nohidden(path):
                path = root_path + '/' + bplen + '/' + seq_err_rate + '/' + mut_rate
                key = seq_err_rate + "," + mut_rate
                if key not in runtimes:
                    runtimes[key] = []
                runtime = runtimeFromREADMEdig(path + '/README.dig')
                runtimes[key].append({'runtime': runtime, 'bplen': bplen})
    return runtimes

plot_data_points['bwa'] = get_runtimes(BWA_FILES_PATH, 'bwa')
plot_data_points['iG'] = get_runtimes(IG_FILES_PATH, 'iG')
print(plot_data_points['iG'])
# Draw a single vertical line for each reference length

READ_LEN_STR = 'read_len'
BP_STR = 'bp'

# a) Plot bwa runtime, note: the same keys are present in both iG and BWA
for key in sorted(plot_data_points['iG']):
    plotDataPtIG = plot_data_points['iG'][key]
    sortedPlotPtIG = sorted(plotDataPtIG, key=lambda x:int(x['bplen'][len(READ_LEN_STR):-len(BP_STR)]))
    runtimesIG = [singlePt['runtime'] for singlePt in sortedPlotPtIG]
    (seq_err_rate, mut_rate) = key.split(',')
    label =  seq_err_rate + ' | ' + mut_rate
    
    plotDataPtBWA = plot_data_points['bwa'][key]
    sortedPlotPtBWA = sorted(plotDataPtBWA, key=lambda x:int(x['bplen'][len(READ_LEN_STR):-len(BP_STR)]))
    runtimesBWA = [singlePt['runtime'] for singlePt in sortedPlotPtBWA]
    plt.plot(runtimesBWA, runtimesIG, label=label, linewidth=LINE_WIDTH)

plt.legend(loc=0,prop={'size':6})
plt.savefig(PLOT_PATH)
plt.gcf().clear()
