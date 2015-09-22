#! /bin/bash
# generate sample features concatenations from every training lists 
# parameter 1: splitlists dir path
# parameter 2: dataset result path
# parameter 3: code dir
# Example:
# sh generate_jobs_train_concatenation.sh /sequoia/data2/gcheron/dummy/splitlists /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code


if [ $# -ne 3 ];
then   
        echo "illegal number of parameters"
        exit
fi


LISTDIR=$1
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_train_concat.txt
JOBEXT=_train_concat.pbs
LOGPATH=$2/jobs/logs/train_concat
EXECPATH=$3/features_concatenation_wrt_name.sh
CONCATDIR=$2/concatenations
TRAINFVEXT=".sub"


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
                SAVENAME=$CONCATDIR/all.$trainame.features${TRAINFVEXT}.${desc}
		# check if feature already exists
                if [ -a $SAVENAME ]
                then   
                        continue
                fi
                JOBNAME=${trainame}_${desc}$JOBEXT

		{
		echo "#$ -l mem_req=5000m"
		echo "#$ -l h_vmem=5000m"
		echo "#$ -j y"
		echo "#$ -o $LOGPATH"
		echo "#$ -N train_concat.$INDEX"
		echo "#$ -q all.q,goodboy.q"
		echo "echo '${trainame}'$'\n'"
		
		echo " sh $EXECPATH $trainset  1 $2 $desc '$SAVENAME'"
		echo "echo '$JOBNAME' >> $LOGPATH/done.log"  # job is done
		} > $JOBPATH/$JOBNAME # create job
		echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME  # put job in the jobs list
		INDEX=$((INDEX+1))
	done
done
