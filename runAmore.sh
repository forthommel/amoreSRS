#!/bin/zsh
# usage:
# ./runAmore.sh <Data Directory> <amoreSRS Base Directory>
# example:
# source ../runAmore.sh /data/GE11-VII-L-CERN-0001 $AMORESRS

#Store the original directory
DIR_ORIGINAL=$PWD
echo "DIR_ORIGINAL = " $DIR_ORIGINAL

#Move to the data directory & store it
cd $1
DIR_DATA=$PWD
echo "DIR_DATA = " $DIR_DATA

#Store physical filename (PFN) of the amore config file
AMORE_CFG=$2/configFileDir/amore.cfg
AMORE_CFG_TEMPLATE=$2/configFileDir/amoreTemplate.cfg
echo "AMORE_CFG = " $AMORE_CFG
echo "AMORE_CFG_TEMPLATE = " $AMORE_CFG_TEMPLATE

#Tell the user which group of files will be analyzed
#echo "The list of files to be copied is:"
#for f in $FILES\;
#do
#	echo $f
#done

#Begin processing the files in $FILES
echo "Beginning to analyze raw data files"
for f in GE11*.raw
do
	#Parse the input filename and setup the new amore config file
	OUTPUTFILENAME="${f/.raw/}"
	OUTPUTFILENAME=$DIR_DATA/$OUTPUTFILENAME
	echo "Analyzing: " $OUTPUTFILENAME
	sed "s@NAMEOFRUNGOESHERE@$OUTPUTFILENAME@g" $AMORE_CFG_TEMPLATE > temp.cfg
	cp temp.cfg $AMORE_CFG
	#rm temp.cfg

	#Try to find the number of events
	FIELD_EVT="kEvt.raw"
	N_CYCLES=0
	for substr in $(echo $f | tr "_" "\n")
	do
		#echo $substr
		#String comparison, search to find number of cycles!
		if echo $substr | grep -q $FIELD_EVT
		then
			#echo $substr " contains $FIELD_EVT"
			#echo $substr | sed 's/[^0-9]*//g'
			N_CYCLES=$(echo $substr | sed 's/[^0-9]*//g')
			#echo "N_CYCLES = " $N_CYCLES
			break
		#else
			#echo "No match"
		fi
	done

	if [ $N_CYCLES -gt 0 ]
	then
		#echo amoreAgent -a SRS01 -s $f -e 1000 -c $N_CYCLES
		amoreAgent -a SRS01 -s $f -e 1000 -c $N_CYCLES
	else
		echo "Skipping $f"
		echo "Filename must contain N$FIELD_EVT where N is an integer"
	fi
done

#End of script, return to original directory
cd $DIR_ORIGINAL
