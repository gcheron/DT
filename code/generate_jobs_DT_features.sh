#! /bin/bash
# compute densetrajectories from the list
# parameter 1: video list path
# parameter 2: dataset result path
# Example:
# sh generate_jobs_DT_features.sh /sequoia/data2/gcheron/dummy/videos/video_list.txt /sequoia/data2/gcheron/CVPR14/features/dummy

echo "DT"

if [ $# -ne 2 ]; 
then
        echo "illegal number of parameters"
        exit
fi



VIDEODIR=$(dirname $1)
VIDEOLISTPATH=$1
FEATDIR=$2/improved_dense_trajectories
EXECPATH=/meleze/data0/bojanows/improved-trajectories/stab_final/release64/DenseTrack
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_DT.txt
JOBEXT=_DT.pbs
LOGPATH=$2/jobs/logs/improved-trajectories
EXPORT1="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT2="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"

rm -rf $LOGPATH
mkdir -p $LOGPATH

INDEX=0
rm -f $JOBLISTNAME

while read vidid
do
	vid=$(basename $vidid)
	vidwe=${vid%.avi}
	featres=${FEATDIR}/${vidwe}.features
	# check if feature already exists
	
	if [ -a $featres ]
	then
		continue
	fi
echo $featres
	{
	echo "#$ -l mem_req=4000m"
        echo "#$ -l h_vmem=4000m"
        echo "#$ -j y"
        echo "#$ -o $LOGPATH"
        echo "#$ -N dense_trajectories.$INDEX"
        echo "#$ -q all.q,goodboy.q"
	echo $EXPORT1
        echo $EXPORT2
	echo "echo \$LD_LIBRARY_PATH"
	echo "echo \"${vid}\""
	echo "${EXECPATH} \"${VIDEODIR}/${vid}\" > \"$featres\""
	echo "echo \"${vidwe}$JOBEXT\" >> $LOGPATH/done.log"
	} > $JOBPATH/${vidwe}$JOBEXT
	echo "$JOBPATH/${vidwe}$JOBEXT" >> $JOBLISTNAME
	INDEX=$((INDEX+1))

done < $VIDEOLISTPATH
