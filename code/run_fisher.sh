#! /bin/bash
# compute the fisher vector of feature wrt pca plan / gmm 
# parameter 1: feature path (whithout feature extention (e.g. ".hog"))
# parameter 2: pca plan/gmm name
# parameter 3: K (number of gaussians used in GMM)
# parameter 4: savename path
# parameter 5: descriptor name
# parameter 6: dataset result path
# Example:
# sh run_fisher.sh /sequoia/data2/laptev/video/mmdb/MMDBrev1.0/Features/cutting/seq1_book0_child.features train1_book 


if [ $# -ne 6 ];
then   
        echo "illegal number of parameters"
        exit
fi



FISHERDIR=$6/fisher
EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/fisher.py
#EXECPATH=/meleze/data0/bojanows/improved-trajectories/export/fisher_test_pyr.py
PCADIR=$6/pca
GMMDIR=$6/gmm

k=$3
SAVENAME=$4
desc=$5

echo "cat '$1.${desc}' | $EXECPATH $PCADIR/pca.$2_${desc}.npz $GMMDIR/$2_${desc}_k${k}.gmm '$SAVENAME'" $'\n'
      cat "$1.${desc}" | $EXECPATH $PCADIR/pca.$2_${desc}.npz $GMMDIR/$2_${desc}_k${k}.gmm "$SAVENAME"

