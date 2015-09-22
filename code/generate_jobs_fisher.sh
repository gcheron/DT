#! /bin/bash
# compute the fisher vector of the list wrt to the pca plan and the gmm
# parameter 1: sequences name and plan list
# parameter 2: dataset result path
# parameter 3: code dir
# Example:
# sh generate_jobs_fisher.sh train_test_pairlist_pcaplan.txt /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code



if [ $# -ne 3 ];
then   
        echo "illegal number of parameters"
        exit
fi



JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_fisher.txt
JOBEXT=_fisher.pbs
LOGPATH=$2/jobs/logs/fisher
EXECPATH=$3/run_fisher.sh
CUTDIR=$2/cutting
FISHERDIR=$2/fisher

rm -rf $LOGPATH
mkdir $LOGPATH



EXPORT1="export PATH=/meleze/data0/local/bin:$PATH"
EXPORT2="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT3="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"
EXPORT4="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sequoia/data2/laptev/video/mmdb/MMDBrev1.0/Features/jobs/lib:"
EXPORT5="export PYTHONPATH=$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:"

INDEX=0
rm -f $JOBLISTNAME
k=256
DESC=(hog hof mbhx mbhy)

while read vidid
do

	vid=$(echo $vidid | cut -d " " -f1)
        pcaplan=$(echo $vidid | cut -d " " -f2)
	vidwe=$(basename ${vid%.avi})

	SAVEDIR=$FISHERDIR/$pcaplan
	mkdir -p $SAVEDIR

        for ((i = 0; i < ${#DESC[@]}; i++))
        do
                desc=${DESC[i]}
                SAVENAME=$SAVEDIR/${vidwe}_${desc}_k${k}.fisher.gz
		# check if feature already exists
      		if [ -a $SAVENAME ]
                then
                        continue
                fi

		JOBNAME=${vidwe}_${pcaplan}_${desc}$JOBEXT
		{
			echo "#$ -l mem_req=4000m"
			echo "#$ -l h_vmem=4000m"
			echo "#$ -j y"
			echo "#$ -o $LOGPATH"
			echo "#$ -N fisher.$INDEX"
			echo "#$ -q all.q,goodboy.q"
			echo $EXPORT1
			echo $EXPORT2
			echo $EXPORT3
			echo $EXPORT4
			echo $EXPORT5
			echo "echo \$LD_LIBRARY_PATH"
			echo "echo '${vid}' $'\n'"
		
			echo "sh $EXECPATH '$CUTDIR/$vidwe.features' $pcaplan $k '$SAVENAME' $desc $2"
			echo "echo '$JOBNAME' >> $LOGPATH/done.log"
		} > $JOBPATH/$JOBNAME
	
		echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME
	
		INDEX=$((INDEX+1))
	done
done < $1

