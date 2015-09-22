#! /bin/bash
# compute densetrajectories from the list
# parameter 1: job name (for which one we are waiting)
# Example:
# sh wait_end_job_named.sh dense_traj 



if [ $# -ne 1 ]; 
then
        echo "illegal number of parameters"
        exit
fi

QSTAT="qstat"


while true 
do
	COUNTERJOBS=`$QSTAT | grep "$1" | wc -l` 
	if [ $COUNTERJOBS -ge 1  ]; then  
		sleep 5 ;
		continue	
	fi 
	break
done 
echo "$1 done!"

