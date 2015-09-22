#! /bin/bash
# get pair list of all the training sets
# a pair is: 1) name of the sequence 2) name of the pca plan
# parameter 1: splitlists dir path
# parameter 2: dataset result path
# Example:
# sh write_trainconcat_pairlist_pcaplan.sh /sequoia/data2/gcheron/dummy/splitlists /sequoia/data2/gcheron/CVPR14/features/dummy
if [ $# -ne 2 ]; 
then
        echo "illegal number of parameters"
        exit
fi

LISTDIR=$1
LISTRESPATH=$2/jobs/trainconcat_pairlist_pcaplan.txt

rm -f $LISTRESPATH

for trainset in $LISTDIR/*_train*
do
        trainame=$(basename ${trainset%.*})
	echo "all.$trainame.features.sub $trainame" >> $LISTRESPATH
done

