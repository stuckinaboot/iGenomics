from sys import argv
file1 = open(argv[1], 'r')
file2 = open(argv[2], 'r')

file1Lines = []
file2Lines = []

for line in file1.readlines():
    file1Lines.append(line)

for line in file2.readlines():
    file2Lines.append(line)

file1.close()
file2.close()

for line in file1Lines:
    if line not in file2Lines:
        print(line + " failed")

for line in file2Lines:
    if line not in file1Lines:
        print(line + " failed")
print("Finished")
