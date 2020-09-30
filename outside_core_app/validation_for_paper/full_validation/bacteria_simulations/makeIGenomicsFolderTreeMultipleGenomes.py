from sys import argv
import os

AUTO_IG_FOLDER_TREE_PATH = '/Users/Stuckinaboot/Downloads/iGenomics/validation_for_paper/full_validation/auto_igenomics_folder_tree.py'

def createDirectoryAtPath(path):
    try:
        os.makedirs(path)
    except:
        pass
for fileName in os.listdir(argv[1]):
    if '.vcf' in fileName:
        components = fileName.split('-')
        path = argv[1] + components[0] + '/'
        createDirectoryAtPath(path)
        os.system('mv ' + argv[1] + components[0] + '* ' + path)
        os.system('python ' + AUTO_IG_FOLDER_TREE_PATH + ' ' + components[0] + '.fa ' + path) 
