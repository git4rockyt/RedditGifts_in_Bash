#!/bin/bash


./ss-list.sh
for i in `cat sorted-master.txt`; do echo "$RANDOM $i"; done | sort | sed -r 's/^[0-9]+ //' > unsorted-master.txt
mkdir run
cp unsorted-master.txt run/master.inp
cp -f prg.sh run/
cd run
./prg.sh
mv op.txt ../
cd ../
