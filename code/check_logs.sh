#! bin/bash
#check some keywords inside logs
# parameter 1: log directory

echo -e "CHECK LOGS"
if [ $# -ne 1 ]; 
then
        echo "illegal number of parameters"
        exit
fi


keywords="-e error -e exception -e failure -e traceback -e found -e fail -assertion"
keywordsent1="no such file or directory"

errorfound=0

for cdir in $1/*
do
	if [ -d "${cdir}" ];
	then
		echo -e "\n \n $cdir \n"

		for fil in $cdir/*
		do
			grep -i -e "$keywordsent1" $keywords $fil

			if [ $? -eq 0 ]
				then echo -e "in File: $fil \n "
				errorfound=1 
			fi
		done
	fi
done

exit $errorfound
