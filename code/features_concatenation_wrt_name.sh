#!/bin/bash
# concatenate sequences features present in the list
# parameter 1: sequences name list
# parameter 2: train FV (if 1: will use the subsampled features, otherwise: use entire features)
# parameter 3: dataset result path
# parameter 4: descriptor name
# parameter 5: savename
# Example:
# sh features_concatenation_wrt_name.sh /sequoia/data2/gcheron/dummy/splitlists/dummy_train1.txt 1 /sequoia/data2/gcheron/CVPR14/features/dummy hog

if [ $# -ne 5 ]; 
then
	echo "illegal number of parameters"
	exit
fi

# do we train FV?
if [ $2 -eq 1 ]
then
	TRAINFVEXT=".sub"
	CUTDIR=$3/cutting/subsampled
else
	TRAINFVEXT=""
	CUTDIR=$3/cutting
fi
desc=$4
SAVENAME=$5	
SAVETMP=${SAVENAME}_TMP
rm -f $SAVETMP	
echo $SAVENAME
echo $SAVETMP

while read vidal
do
	vids=$(echo $vidal | cut -d " " -f1) # remove the label
	vid=$(basename ${vids%.*})  # keep only the seq name
	echo $vid
	cat "$CUTDIR/${vid}.features${TRAINFVEXT}.${desc}" >> $SAVETMP
done < $1

mv $SAVETMP $SAVENAME


