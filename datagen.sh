#!/bin/bash


cn=$1;
pr=$2;
nwill=$3;
will=$4;

cntb=${pr}00001;
cnte=`expr ${cntb} + ${nwill}`;
cnte=`expr ${cnte} - 1`;

for x in $(seq --format=%1.f $cntb $cnte); do
	echo "$x,$cn,False"; 
done;

cntb=`expr $cnte + 1`;
cnte=`expr ${cntb} + ${will}`;
cnte=`expr ${cnte} - 1`;

for x in $(seq --format=%1.f $cntb $cnte); do
	echo "$x,$cn,True"; 
done;
