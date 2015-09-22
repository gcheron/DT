#! /bin/bash
# generate sample features gmm from every training lists 
# parameter 1: splitlists dir path
# parameter 2: dataset result path
# parameter 3: code dir
# Example:
# sh generate_jobs_train_gmm.sh /sequoia/data2/gcheron/dummy/splitlists /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code


if [ $# -ne 3 ];
then   
        echo "illegal number of parameters"
        exit
fi


LISTDIR=$1
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_gmm.txt
JOBEXT=_gmm.pbs
LOGPATH=$2/jobs/logs/gmm
EXECPATH=$3/compute_gmm.sh
GMMDIR=$2/gmm

rm -rf $LOGPATH
mkdir -p $LOGPATH

INDEX=0
rm -f $JOBLISTNAME


# for descriptors
DESC=(hog hof mbhx mbhy)

k=256

for trainset in $LISTDIR/*_train*
do
	trainame=$(basename ${trainset%.*})	
	
	for ((i = 0; i < ${#DESC[@]}; i++))
	do
		desc=${DESC[i]}
		JOBNAME=${trainame}_${desc}$JOBEXT
                SAVENAME=$GMMDIR/${trainame}_${desc}_k${k}.gmm


                if [ -a $SAVENAME ] # check if already computed
                then   
                        continue
                fi


		{
		echo "#$ -l mem_req=4000m"
		echo "#$ -l h_vmem=5000m"
		echo "#$ -j y"
		echo "#$ -o $LOGPATH"
		echo "#$ -N gmm.$INDEX"
		echo "#$ -q all.q,goodboy.q"
		echo "echo ${trainame} $desc $'\n'"
		
		echo "sh $EXECPATH '$trainame' $desc '$SAVENAME' $k $2 $3"  
		echo "echo '$JOBNAME' >> $LOGPATH/done.log"  # job is done
		} > $JOBPATH/$JOBNAME # create job
		echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME  # put job in the jobs list
		INDEX=$((INDEX+1))
	done
done 

