#! /bin/bash
# compute the fisher vector of the list wrt to the pca plan and the gmm
# parameter 1: sequences name and plan list
# parameter 2: dataset result path
# Example:
# sh generate_jobs_fisher.sh train_test_pairlist_pcaplan.txt /sequoia/data2/gcheron/CVPR14/features/dummy



if [ $# -ne 2 ];
then   
        echo "illegal number of parameters"
        exit
fi



JOBPATH=$2/jobs/qsub_jobs
JOBLISTNAME=$2/jobs/joblist_fisher_pyr.txt
JOBEXT=_fisher_pyr.pbs
LOGPATH=$2/jobs/logs/fisher_pyr
CUTDIR=$2/cutting
FISHERDIR=$2/fisher_pyr
FEATDIR=$2/improved_dense_trajectories
PCADIR=$2/pca
GMMDIR=$2/gmm
EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/fisher_test_pyr.py

rm -rf $LOGPATH
mkdir $LOGPATH


EXPORT1="export PATH=/meleze/data0/local/bin:$PATH"
EXPORT2="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:"
EXPORT3="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:"
EXPORT4="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sequoia/data1/gcheron/general-code/DT/code/lib:"
EXPORT5="export PYTHONPATH=$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:"

INDEX=0
rm -f $JOBLISTNAME
k=256
DESC=(hog hof mbhx mbhy)

nxy=2
nt=3

# relative position for pyramids
pos_begin=6
pos_end=8

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

# for k
k=256
num=$((k*1000))

while read vidid
do

	vid=$(echo $vidid | cut -d " " -f1)
        pcaplan=$(echo $vidid | cut -d " " -f2)
	vidwe=$(basename ${vid%.avi})

	SAVEDIR=$FISHERDIR/$pcaplan
	mkdir -p $SAVEDIR
	
        # check if the last feature already exists
	i=$((${#DESC[@]}-1))
	desc=${DESC[i]}
        SAVENAME=$SAVEDIR/${vidwe}_${desc}_k${k}.fisher.gz
        if [ -a $SAVENAME ]
        then
        	continue
        fi
	JOBNAME=${vidwe}_${pcaplan}$JOBEXT	
	{
		echo "#$ -l mem_req=4000m"
		echo "#$ -l h_vmem=4000m"
		echo "#$ -j y"
		echo "#$ -o $LOGPATH"
		echo "#$ -N fisher_pyr.$INDEX"
		echo "#$ -q all.q,goodboy.q"
		echo $EXPORT1
		echo $EXPORT2
		echo $EXPORT3
		echo $EXPORT4
		echo $EXPORT5
		echo "echo \$LD_LIBRARY_PATH"
		echo "echo '${vid}' $'\n'"

		PARAMS=""
        	for ((i = 0; i < ${#DESC[@]}; i++))
        	do
                	desc=${DESC[i]}
                	PARAMS="$PARAMS $PCADIR/pca.${pcaplan}_${desc}.npz $GMMDIR/${pcaplan}_${desc}_k${k}.gmm '$SAVEDIR/${vidwe}_${desc}_k${k}.fisher.gz'"
        	done

		TMPCUT=$FEATDIR/$vidwe.features.cut_$pcaplan	
        	echo "cat '$FEATDIR/$vidwe.features' | cut -d$'\t' -f ${pos_begin}-${pos_end},${hog_begin}-${mbhy_end} > '$TMPCUT'"
        
		echo "cat '$TMPCUT' | $EXECPATH $PARAMS"

		echo "rm  '$TMPCUT'"
	} > $JOBPATH/$JOBNAME	
	echo "$JOBPATH/$JOBNAME" >> $JOBLISTNAME
	
	INDEX=$((INDEX+1))

done < $1

