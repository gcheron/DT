#!/bin/bash
# compute pca plan from the sequences descripor concatenation
# parameter 1: concatenation name (whithout feature extention (e.g. ".hog"))
# parameter 2: descriptor name
# parameter 3: dataset result path
# parameter 4: savename path
# Example:
# sh compute_pca dummy_train1 hog /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/dummy/pca/pca.dummy_train1_hog.npz


if [ $# -ne 4 ]; 
then
	echo "illegal number of parameters"
	exit
fi


CONCATDIR=$3/concatenations
EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/pca_train.py

export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:
export PYTHONPATH=\$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:

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


hog_pca=$(((hog_end-hog_begin+1)/2))
hof_pca=$(((hof_end-hof_begin+1)/2))
mbhx_pca=$(((mbhx_end-mbhx_begin+1)/2))
mbhy_pca=$(((mbhy_end-mbhy_begin+1)/2))

desc=$2
echo $desc
INNAME=$CONCATDIR/all.$1.features.sub.${desc}
SAVENAME=$4	

num=$(cat $INNAME | wc -l)
eval "begin=\$${desc}_begin"
eval "end=\$${desc}_end"
dimIn=$((end-begin+1))
eval "dimOut=\$${desc}_pca"
echo $'\n' $'\n'
echo "cat '$INNAME' | $EXECPATH $num $dimIn $dimOut '$SAVENAME'"
echo $'\n'
cat "$INNAME" | $EXECPATH $num $dimIn $dimOut "$SAVENAME"
