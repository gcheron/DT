#! /bin/bash
# generate sample features pca plan from every training lists 
# parameter 1: splitlists dir path
# parameter 2: dataset result path
# parameter 3: code dir
# Example:
# sh generate_jobs_train_pca.sh /sequoia/data2/gcheron/dummy/splitlists /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code

if [ $# -ne 3 ]; 
then
        echo "illegal number of parameters"
        exit
fi



LISTDIR=$1
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_pca.txt
JOBEXT=_pca.pbs
LOGPATH=$2/jobs/logs/pca
EXECPATH=$3/compute_pca.sh
PCADIR=$2/pca

rm -rf $LOGPATH
mkdir -p $LOGPATH

INDEX=0
rm -f $JOBLISTNAME


# for descriptors
DESC=(hog hof mbhx mbhy)



for trainset in $LISTDIR/*_train*
do
	trainame=$(basename ${trainset%.*})	
	
	for ((i = 0; i < ${#DESC[@]}; i++))
	do
		desc=${DESC[i]}
		JOBNAME=${trainame}_${desc}$JOBEXT
		SAVENAME=$PCADIR/pca.${trainame}_${desc}.npz
		

		if [ -a $SAVENAME ] # check if already computed
		then   
        		continue
		fi

		{
		echo "#$ -l mem_req=15000m"
		echo "#$ -l h_vmem=15000m"
		echo "#$ -j y"
		echo "#$ -o $LOGPATH"
		echo "#$ -N pca.$INDEX"
		echo "#$ -q all.q,goodboy.q"
		echo "echo ${trainame} $desc $'\n'"
		
		echo "sh $EXECPATH '$trainame' $desc $2 '$SAVENAME'"  
		echo "echo '$JOBNAME' >> $LOGPATH/done.log"  # job is done
		} > $JOBPATH/$JOBNAME # create job
		echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME  # put job in the jobs list
		INDEX=$((INDEX+1))
	done
done 

