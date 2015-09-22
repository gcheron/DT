#! /bin/bash
# projection of the 5 chanels feature wrt pca plan
# parameter 1: feature path (whithout feature extention (e.g. ".hog"))
# parameter 2: pca plan name 
# parameter 3: dataset result path
# parameter 4: savename path
# parameter 5: descriptor name
# Example:
# sh run_projection.sh /sequoia/data2/gcheron/CVPR14/features/dummy/cutting/vid1.features dummy_train1 
# or
# sh run_projection.sh /sequoia/data2/laptev/video/mmdb/MMDBrev1.0/Features/concatenations/all.dummy_train2.features.sub dumm_train1


if [ $# -ne 5 ]; 
then
	echo "illegal number of parameters"
	exit
fi

PCADIR=$3/pca
EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/pca_test.py

# for descriptors
DESC=(hog hof mbhx mbhy)

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


track_pca=$(((track_end-track_begin+1)/2))
hog_pca=$(((hog_end-hog_begin+1)/2))
hof_pca=$(((hof_end-hof_begin+1)/2))
mbhx_pca=$(((mbhx_end-mbhx_begin+1)/2))
mbhy_pca=$(((mbhy_end-mbhy_begin+1)/2))

desc=$5

INNAME=$1.${desc}
PCANAME=$PCADIR/pca.$2_${desc}.npz
SAVENAME=$4

num=$(cat "$INNAME" | wc -l)
echo $'\n' "we have $num samples" $'\n'
eval "begin=\$${desc}_begin"
eval "end=\$${desc}_end"
dimIn=$((end-begin+1))
eval "dimOut=\$${desc}_pca"
echo "cat '$INNAME' | $EXECPATH $num $dimIn $dimOut $PCANAME '$SAVENAME'"  $'\n'
cat "$INNAME" | $EXECPATH $num $dimIn $dimOut $PCANAME "$SAVENAME"
echo $'\n' $'\n'
