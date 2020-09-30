from sys import argv

f = open(argv[1])
o = open(argv[1].replace('.fa', '.fq').replace('.fasta', '.fastq'), 'w')

output = ''
prevReadSeq = ''
for i, line in enumerate(f.readlines()):
    if i % 2 == 0:
        output += line
    elif i % 2 == 1:
        output += line
        prevReadSeq = line.replace('\n','')
        output += '+\n'
        output += '!' * len(prevReadSeq) + '\n'
o.write(output)
o.close()
f.close()
    
