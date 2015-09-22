#!/bin/sh 

QSTAT="qstat"
QSUB="qsub"
USER=gcheron 

jobnbpath="/sequoia/data2/gcheron/DT/code/job_nb.txt"

if [ $# -ne 1 ]; 
then
        echo "illegal number of parameters"
        exit
fi

JOBLISTPATH=$1

if [ -a $JOBLISTPATH ]
then

COUNTERJOBS=`$QSTAT | grep $USER | wc -l` 

jobn=$(eval "cat $JOBLISTPATH | wc -l")
INDEX=1
while read JOBID 
do 
	max_num_job=`cat $jobnbpath`
	if [ "$COUNTERJOBS" -ge "$max_num_job" ]; then 
		echo "maximum job number reached: $max_num_job"
		while [ "$COUNTERJOBS" -ge "$max_num_job" ] || [ "$quit" == "q" ] || [ "$quit" == "Q" ]; do 
			sleep 5 
			COUNTERJOBS=`$QSTAT | grep $USER | wc -l` 
			max_num_job=`cat $jobnbpath`
		done
		echo "Restart to launch jobs..." 
	fi 
	echo "Job $INDEX out of $jobn"
	$QSUB $JOBID 
	sleep 0.1 
	COUNTERJOBS=`$QSTAT | grep $USER | wc -l` 
	
	INDEX=$((INDEX+1))

done < $JOBLISTPATH
fi
