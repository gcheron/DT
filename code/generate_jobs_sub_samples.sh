#! /bin/bash
# compute densetrajectories from the list
# parameter 1: video list path
# parameter 2: dataset result path
# parameter 3: number of wanted trajectory features for training pca and gmm
# parameter 4: number of examples in the training list
# Example:
# sh generate_jobs_sub_samples.sh /sequoia/data2/gcheron/dummy/videos/video_list.txt /sequoia/data2/gcheron/CVPR14/features/dummy 5000 3



if [ $# -ne 4 ]; 
then
        echo "illegal number of parameters"
        exit
fi



VIDEOLISTPATH=$1
FEATDIR=$2/improved_dense_trajectories
EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/subsample.py
JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_sub_sample.txt
JOBEXT=_sub_sample.pbs
LOGPATH=$2/jobs/logs/sub-traj
SUBSAMPLEDIR=$2/sub-traj


rm -rf $LOGPATH
mkdir $LOGPATH


EXPORT0="export PATH=/meleze/data0/local/bin:\$PATH"
EXPORT1="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT2="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"
EXPORT3="export PYTHONPATH=\$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:"

INDEX=0
rm -f $JOBLISTNAME

wantsize=$3 # wanted concatenate feature size (in the number of trajectories) at the end
nbsamples=$4 # number of training samples that will be concatenated
nbextractperex=$((wantsize/nbsamples)) # number of trajectories to extract per sample

# Subsample features from clips in order to compute PCA on those
while read vidid
do
	vid=$(basename $vidid)
	vidwe=${vid%.avi}
        featres=${SUBSAMPLEDIR}/$vidwe.features.sub

        # check if feature already exists
        if [ -a $featres ]
        then
                continue
        fi

	{
	echo "#$ -l mem_req=4000m"
	echo "#$ -l h_vmem=4000m"
	echo "#$ -j y"
	echo "#$ -o $LOGPATH"
	echo "#$ -N sub_sample.$INDEX"
	echo "#$ -q all.q,goodboy.q"
	echo $EXPORT0
	echo $EXPORT1
	echo $EXPORT2
	echo $EXPORT3
	echo "echo \$LD_LIBRARY_PATH"
	echo "echo \"${vid}\""
	echo "sample_num=\$(eval \"cat '${FEATDIR}/$vidwe.features' | wc -l\")"  # number of trajectories in the current sample
	echo "sample_ratio=0\$( echo \"scale=3 ; $nbextractperex / \$sample_num\" | bc )"
	echo "if [ \$(echo \" \$sample_ratio > 1 \" | bc) -eq 1 ]"
	echo "	then sample_ratio=1.00"
	echo "fi"

        echo "if [ \$(echo \" \$sample_ratio <= 0 \" | bc) -eq 1 ]"
        echo "  then sample_ratio=0.0001"
        echo "fi"


	echo "echo $'\n'$wantsize $nbsamples $nbextractperex"
	echo "echo \"\$sample_num \$sample_ratio\""
	echo "echo \$sample_ratio" $'\n'

	echo "cat \"${FEATDIR}/$vidwe.features\" | ${EXECPATH} \$sample_ratio > '$featres'"
	echo "echo \"${vidwe}$JOBEXT\" >> $LOGPATH/done.log"
	} > $JOBPATH/${vidwe}$JOBEXT
	echo "$JOBPATH/${vidwe}$JOBEXT" >> $JOBLISTNAME
	INDEX=$((INDEX+1))
done < $VIDEOLISTPATH
