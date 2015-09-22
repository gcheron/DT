#!/bin/bash
# compute gmm 
# parameter 1: projected concatenation name (whithout feature extention (e.g. ".hog"))
# parameter 2: descriptor name
# parameter 3: savename
# parameter 4: K (number of gaussians)
# parameter 5: dataset result path
# parameter 6: code dir
# Example:
# sh compute_gmm.sh dummy_train1 hog dummy_train1_hog_256.gmm 256 /sequoia/data2/gcheron/CVPR14/features/dummy /sequoia/data2/gcheron/CVPR14/features/code



if [ $# -ne 6 ]; 
then
	echo "illegal number of parameters"
	exit
fi

PROJDIR=$5/proj/$1
EXECPATH=$6/export/gmm_train.py


k=$4




export PATH=/meleze/data0/local/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/meleze/data0/bojanows/improved-trajectories/local/lib:
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cm/shared/apps/gcc/4.8.1/lib:/cm/shared/apps/gcc/4.8.1/lib64:
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$6/lib:
export PYTHONPATH=$PYTHONPATH:/meleze/data0/bojanows/improved-trajectories/yael_v318:

echo $PATH
echo $LD_LIBRARY_PATH
echo $PYTHONPATH


desc=$2

INNAME=$PROJDIR/projected_all.$1.features.sub_${desc}.npy
SAVENAME=$3	

echo "cat $EXECPATH '$INNAME' $k '$SAVENAME'"
python $EXECPATH "$INNAME" $k "$SAVENAME"
