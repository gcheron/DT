#! /bin/bash
# uncompress fisher vectors in "raw" directory
# parameter 1: dataset result path
# Example:
# sh uncompress_fysher.sh /sequoia/data2/gcheron/CVPR14/features/dummy



if [ $# -ne 1 ];
then   
        echo "illegal number of parameters"
        exit
fi

FISHERDIR=$1/fisher_pyr




for dir in $FISHERDIR/*
do
	basdir=$(basename $dir)
	rawdir=$FISHERDIR/raw/$basdir
	mkdir -p $rawdir
	echo $dir
	echo $rawdir
	
	for fish in $dir/*.gz
	do
		fishres=$(basename ${fish%*.gz})	
		gunzip -c "$fish" > "$rawdir/$fishres"
	done
done

