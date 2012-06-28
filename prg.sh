#!/bin/bash


randomize() {

	fileIn=$1;
	fileOut=`echo $fileIn | sed -e "s/\.tmp/-rnd.tmp/g"`;
	for x in `cat $fileIn`; do echo "$RANDOM:$x"; done | sort | sed -r "s/^[0-9]+://" > $fileOut;

}

rndrobin() {
	fileIn=$1;
	fileOut=`echo $fileIn | sed -e "s/\.tmp/-rr.tmp/g"`;

	firstLn=`head -n1 $fileIn`;
	prevLn=$firstLn;

	for ln in `cat $fileIn`; do
		echo "$prevLn,$ln" >> $fileOut;
		prevLn=$ln;
	done;
	echo "$prevLn,$firstLn" >> $fileOut;
	cat $fileOut | grep -v "$firstLn,$firstLn" > ${fileOut}-tmp
	mv ${fileOut}-tmp $fileOut
}

runIntl() {

	randomize intl1.tmp
	randomize intl2.tmp
	sdiff intl1-rnd.tmp intl2-rnd.tmp | awk '{print $1","$3}' > round1.tmp
	randomize intl1.tmp
	randomize intl2.tmp
	sdiff intl2-rnd.tmp intl1-rnd.tmp | awk '{print $1","$3}' > round2.tmp

}

chkIntl() {
	cat round1.tmp | sort > round12.tmp
	cat round2.tmp | sed -r "s/([0-9]+),([0-9]+)/\2,\1/g" | sort > round22.tmp
	commonLines=`comm -1 -2 round12.tmp round22.tmp | wc -l`
	if [ $commonLines -gt 0 ]; then
		#echo "on the international side, some people are exchanging gifts amongs them"
		return -1;
	fi
	return 0;
	
}


COUNTRIES=`cat master.inp | cut -f2 -d"," | sort | uniq`
for CN in $COUNTRIES; do 

	cat master.inp | grep $CN | grep "True" > $CN-intl.tmp
	cat master.inp | grep $CN | grep -v "True" > $CN-dom.tmp
done; 

#date "+%d%b%Y-%H:%M:%S"

# For Domestic

for CN in $COUNTRIES; do
	cat $CN-dom.tmp | cut -f1 -d"," > $CN-dom-id.tmp
	randomize $CN-dom-id.tmp
	rndrobin $CN-dom-id.tmp
	#echo "$CN Finished @ `date "+%d%b%Y-%H:%M:%S"`"
done;	

# For internationals

totIntl=`cat *-intl.tmp | wc -l`

wc -l *-intl.tmp | grep -v total| sort -n | sed -r "s/^[ ]+//g" |cut -f2 -d" " > intl-Cnt.tmp
rm -f whole-intl.tmp
for x in `cat intl-Cnt.tmp`; do
	cat $x >> whole-intl.tmp;
done;

rem=$(($totIntl % 2 ))

if [ $rem -eq 1 ]; then
	# Need to cut 5 entries and make then roundrobin
	tail -n5 whole-intl.tmp | cut -f1 -d","  > intl-rem.tmp
	rndrobin intl-rem.tmp
	totIntl=$((totIntl-5))
	head -n$totIntl whole-intl.tmp > whole-intl-1.tmp 
	mv whole-intl-1.tmp whole-intl.tmp
fi

mid=$(($totIntl / 2))

head -n $mid whole-intl.tmp | cut -f1 -d"," > intl1.tmp
mid=$(($totIntl - $mid))
tail -n $mid whole-intl.tmp | cut -f1 -d"," > intl2.tmp

tries=0;
maxtries=10;
while [ 1 -eq 1 ]; do

	tries=$((tries+1));
	runIntl
	chkIntl

	RC=$?
	
	if [ $RC -eq 0 -o $tries -gt $maxtries ]; then
		break;
	fi
done

cat *-rr.tmp round1.tmp round2.tmp > op.txt
rm -f *.tmp
