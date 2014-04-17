import os, sys, re

EK_DIR = '/auto/iris-00/rn/chensun/features/MED_14/DT_FV/EK_positive'
BG_DIR = '/auto/iris-00/rn/chensun/features/MED_14/DT_FV/EK_bg'
TEST_DIR = '/auto/iris-00/rn/chensun/features/MED_14/DT_FV/MEDTest'

EK_REF = '/auto/iris-00/rn/chensun/MEDDataDivisions-20130501/MEDDATA/databases/EVENTS-10Ex_20130405_JudgementMD.csv'
#EK_REF = '/auto/iris-00/rn/chensun/MEDDataDivisions-20130501/MEDDATA/databases/EVENTS-100Ex_20130405_JudgementMD.csv'
TEST_REF = '/auto/iris-00/rn/chensun/MEDDataDivisions-20130501/MEDDATA/databases/MEDTEST_20130501_Ref.csv'

suffix = '.log'

ekFiles = os.listdir(EK_DIR)
ekFiles = [os.path.join(EK_DIR, ekFile) for ekFile in ekFiles if ekFile.endswith(suffix)]

bgFiles = os.listdir(BG_DIR)
bgFiles = [os.path.join(BG_DIR, bgFile) for bgFile in bgFiles if bgFile.endswith(suffix)]

testFiles = os.listdir(TEST_DIR)
testFiles = [os.path.join(TEST_DIR, testFile) for testFile in testFiles if testFile.endswith(suffix)]

f = open(EK_REF)
ekGTs = [line.rstrip() for line in f.readlines()]
f.close()
ekGTs = [re.findall(r'"(\d+)","E(\d+)","positive"', line) for line in ekGTs]
ekGTs = [(line[0][0], int(line[0][1])) for line in ekGTs if len(line) > 0]
ekGTs = [tup for tup in ekGTs if (tup[1] > 5 and tup[1] < 16) or (tup[1] > 20 and tup[1] < 31)]
ekGTs = dict(ekGTs)

f = open(TEST_REF)
testGTs = [line.rstrip() for line in f.readlines()]
f.close()
testGTs = [re.findall(r'"(\d+).E(\d+)","y"', line) for line in testGTs]
testGTs = [(line[0][0], int(line[0][1])) for line in testGTs if len(line) > 0]
testGTs = [tup for tup in testGTs if (tup[1] > 5 and tup[1] < 16) or (tup[1] > 20 and tup[1] < 31)]
testGTs = dict(testGTs)

# write lists
f = open('lsvm_train.lst', 'w')
for ekFile in ekFiles:
    vID = re.findall(r'HVC(\d+)', ekFile)[0]
    if vID not in ekGTs.keys():
        continue
    f.write('%d %s\n' % (ekGTs[vID], ekFile[:-4]))
for bgFile in bgFiles:
    f.write('-1 %s\n' % bgFile[:-4])
f.close()

f = open('lsvm_test.lst', 'w')
for testFile in testFiles:
    vID = re.findall(r'HVC(\d+)', testFile)[0]
    gt = -1
    if vID in testGTs.keys():
        gt = testGTs[vID]
    f.write('%d %s\n' % (gt, testFile[:-4]))
f.close()

f = open('lsvm_train.lst', 'r')
lines = [line.rstrip() for line in f.readlines()]
f.close()
f = open('lsvm_train.lst', 'w')
f.write('%d\n' % len(lines))
for line in lines:
    f.write('%s\n' % line)
f.close()
f = open('lsvm_test.lst', 'r')
lines = [line.rstrip() for line in f.readlines()]
f.close()
f = open('lsvm_test.lst', 'w')
f.write('%d\n' % len(lines))
for line in lines:
    f.write('%s\n' % line)
f.close()
