#! /bin/bash
# projection of the features in the list wrt pca plan
# parameter 1: sequences name and plan list
# parameter 2: train FV (if 1: will use the subsampled features, otherwise: use entire features)
# parameter 3: dataset result path
# parameter 4: code dir
# Example:
# sh generate_jobs_projections.sh  /sequoia/data2/gcheron/CVPR14/features/dummy/job/trainconcat_pairlist_pcaplan.txt 1 /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code



if [ $# -ne 4 ]; 
then
	echo "illegal number of parameters"
	exit
fi

# do we train FV?
if [ $2 -eq 1 ]
then
	TRAINFVEXT=".sub"
	FEATDIR=$3/concatenations
else
	TRAINFVEXT=""
	FEATDIR=$3/cutting
fi

EXECPATH=$4/run_projection.sh
JOBPATH=$3/jobs/qsub_jobs
JOBLISTNAME=$3/jobs/joblist_project.txt
JOBEXT=_project.pbs
LOGPATH=$3/jobs/logs/project
PROJDIR=$3/proj


rm -rf $LOGPATH
mkdir $LOGPATH


EXPORT0="export PATH=/meleze/data0/local/bin:\$PATH"
EXPORT1="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT2="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"
EXPORT3="export PYTHONPATH=\$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:"

INDEX=0
rm -f $JOBLISTNAME

# for descriptors
DESC=(hog hof mbhx mbhy)



while read vidid
do
	vid=$(echo $vidid | cut -d " " -f1)
	pcaplan=$(echo $vidid | cut -d " " -f2)
	SAVEDIR=$PROJDIR/$pcaplan
	mkdir -p $SAVEDIR

	vidwe=${vid%.avi}

        for ((i = 0; i < ${#DESC[@]}; i++))
        do
                desc=${DESC[i]}
		SAVENAME=$SAVEDIR/projected_${vidwe}_${desc}.npy                
		# check if feature already exists
                if [ -a $SAVENAME ]
                then   
                        continue
                fi

		JOBNAME=${vidwe}_$pcaplan_${desc}$JOBEXT
		{
		echo "#$ -l mem_req=15000m"
		echo "#$ -l h_vmem=15000m"
		echo "#$ -j y"
		echo "#$ -o $LOGPATH"
		echo "#$ -N projection.$INDEX"
		echo "#$ -q all.q,goodboy.q"
		echo $EXPORT0
		echo $EXPORT1
		echo $EXPORT2
		echo $EXPORT3
		#echo "echo \$LD_LIBRARY_PATH"
		echo "echo '${vid}'$'\n'"
		
		echo "sh $EXECPATH '$FEATDIR/$vidwe' $pcaplan $3 '$SAVENAME' $desc"
		echo "echo '$JOBNAME' >> $LOGPATH/done.log"
		} > $JOBPATH/$JOBNAME
		echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME
		INDEX=$((INDEX+1))
	done
done < $1

