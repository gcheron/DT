#! /bin/bash
# get pair list of all the train/test sets
# a pair is: 1) name of the sequence 2) name of the pca plan
# parameter 1: splitlists dir path
# parameter 2: dataset result path
# Example:
# sh write_train_test_pairlist_pcaplan.sh /sequoia/data2/gcheron/dummy/splitlists /sequoia/data2/gcheron/CVPR14/features/dummy

if [ $# -ne 2 ];
then   
        echo "illegal number of parameters"
        exit
fi


LISTDIR=$1
LISTRESPATH=$2/jobs/train_test_pairlist_pcaplan.txt

rm -f $LISTRESPATH



# test
for testset in $LISTDIR/*_test*
do
        testname=$(basename ${testset%.*})

	# find the corresponding (train) plan
	tespos=$(echo $testname | grep -bo test | cut -d ":" -f1)

	trainame="${testname:0:tespos}train${testname:$tespos+4}"
	while read seqp
	do
		seq=$(echo $seqp | cut -d " " -f1)
		echo "$seq $trainame" >> $LISTRESPATH
	done < $testset
done

# train
for trainset in $LISTDIR/*_train*
do
        trainame=$(basename ${trainset%.*})
	while read seqp
	do
		seq=$(echo $seqp | cut -d " " -f1)
		echo "$seq $trainame" >> $LISTRESPATH
	done < $trainset
done

