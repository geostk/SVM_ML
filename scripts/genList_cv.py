import os, sys, re

# Feature directories 
EK_DIR = '/auto/iris-00/rn/chensun/features/MED_14/DT_FV/EK_positive'
BG_DIR = '/auto/iris-00/rn/chensun/features/MED_14/DT_FV/EK_bg'

EK_REF = '/auto/iris-00/rn/chensun/MED_14/lists/all-folds/100Ex+BG'

suffix = '.log'
numFolds = 10

ekFiles = os.listdir(EK_DIR)
ekFiles = [os.path.join(EK_DIR, ekFile) for ekFile in ekFiles if ekFile.endswith(suffix)]

bgFiles = os.listdir(BG_DIR)
bgFiles = [os.path.join(BG_DIR, bgFile) for bgFile in bgFiles if bgFile.endswith(suffix)]

cvTuples = []

for fold in range(numFolds):
    f = open('%s.%d.csv' % (EK_REF, fold))
    lines = [line.rstrip() for line in f.readlines()]
    f.close()
    ekGTs = [re.findall(r'"(\d+)","E(\d+)","positive"', line) for line in lines]
    ekGTs = [(line[0][0], int(line[0][1])) for line in ekGTs if len(line) > 0]
    ekGTs = dict(ekGTs)
    vIDs = [re.findall(r'"(\d+)"', line) for line in lines]
    vIDs = [line[0] for line in vIDs if len(line) > 0]
    vIDs = set(vIDs)  # remove duplicate entries
    for vID in vIDs:
        if vID not in ekGTs.keys():
            ekGTs[vID] = -1
    cvTuples = cvTuples + [(vID, (fold, ekGTs[vID])) for vID in vIDs]

cvTuples = dict(cvTuples)

# write lists
f = open('cv_train.lst', 'w')
for ekFile in ekFiles:
    vID = re.findall(r'HVC(\d+)', ekFile)[0]
    if vID not in cvTuples.keys():
        continue
    f.write('%d %d %s\n' % (cvTuples[vID][1], cvTuples[vID][0], ekFile[:-4]))
for bgFile in bgFiles:
    vID = re.findall(r'HVC(\d+)', bgFile)[0]
    if vID not in cvTuples.keys():
        continue
    f.write('%d %d %s\n' % (cvTuples[vID][1], cvTuples[vID][0], bgFile[:-4]))
f.close()

f = open('cv_train.lst', 'r')
lines = [line.rstrip() for line in f.readlines()]
f.close()
f = open('cv_train.lst', 'w')
f.write('%d\n' % len(lines))
for line in lines:
    f.write('%s\n' % line)
f.close()
