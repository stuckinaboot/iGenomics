# import os
# os.system('clear')
numPassing = float(raw_input('Enter the number passing: '))
totalIGenomics = float(raw_input('Enter the total number from iGenomics: '))
totalBWA = float(raw_input('Enter the total number from BWA: '))

precision = numPassing / totalIGenomics
recall = numPassing / totalBWA
fScore = 2 * precision * recall / (precision + recall)

print 'Precision: ' + str(precision * 100) + '\nRecall: ' + str(recall * 100) + '\nF-Score: ' + str(fScore * 100)