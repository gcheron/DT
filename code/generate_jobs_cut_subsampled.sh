#! /bin/bash
# cut sub features into HOG, HOF MBHx and MBHy descriptiors
# parameter 1: video list path
# parameter 2: dataset result path
# Example:
# sh generate_jobs_cut_subsampled.sh /sequoia/data2/gcheron/dummy/videos/video_list.txt /sequoia/data2/gcheron/CVPR14/features/dummy



if [ $# -ne 2 ]; 
then
        echo "illegal number of parameters"
        exit
fi


VIDEOLISTPATH=$1
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_cutting_subsampled.txt
JOBEXT=_cutting_subsampled.pbs
LOGPATH=$2/jobs/logs/cutting_subsampled
CUTDIR=$2/cutting/subsampled
SUBSAMPLEDIR=$2/sub-traj

rm -rf $LOGPATH
mkdir $LOGPATH


EXPORT1="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT2="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"
EXPORT3="export PYTHONPATH=\$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:"

nxy=2
nt=3

# feature begin position 
pos=11
track_begin=$((pos))
track_end=$((track_begin+30-1))
hog_begin=$((track_end+1))
hog_end=$((hog_begin+nxy*nxy*nt*8-1))
hof_begin=$((hog_end+1))
hof_end=$((hof_begin+nxy*nxy*nt*9-1))
mbhx_begin=$((hof_end+1))
mbhx_end=$((mbhx_begin+nxy*nxy*nt*8-1))
mbhy_begin=$((mbhx_end+1))
mbhy_end=$((mbhy_begin+nxy*nxy*nt*8-1))


# for descriptors
DESC=(hog hof mbhx mbhy)



INDEX=0
rm -f $JOBLISTNAME

# cut features files in 4 chanels (hog hof mbhx mbhy)
while read vidid
do
	vid=$(basename $vidid)
	vidwe=${vid%.avi}


        # check if the last feature already exists
        i=$((${#DESC[@]}-1))
        desc=${DESC[i]}
        featres=$CUTDIR/$vidwe.features.sub.${desc}
        if [ -a $featres ]
        then
                continue
        fi

        JOBNAME=${vidwe}$JOBEXT
	{
	echo "#$ -l mem_req=4000m"
	echo "#$ -l h_vmem=4000m"
	echo "#$ -j y"
	echo "#$ -o $LOGPATH"
	echo "#$ -N cutting_sub.$INDEX"
	echo "#$ -q all.q,goodboy.q"
	echo $EXPORT1
	echo $EXPORT2
	echo $EXPORT3
	echo "echo \$LD_LIBRARY_PATH"
	echo "echo '${vid}'"

        for ((i = 0; i < ${#DESC[@]}; i++))
        do
                desc=${DESC[i]}
       	        featres=$CUTDIR/$vidwe.features.sub.${desc}
		eval "begin=\$${desc}_begin"
		eval "end=\$${desc}_end"
		echo "cat '${SUBSAMPLEDIR}/$vidwe.features.sub' | cut -d$'\t' -f ${begin}-${end} > '$featres'"
	done
	
	echo "echo '$JOBNAME' >> $LOGPATH/done.log"
	} > $JOBPATH/$JOBNAME
	echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME
	INDEX=$((INDEX+1))

done < $VIDEOLISTPATH

