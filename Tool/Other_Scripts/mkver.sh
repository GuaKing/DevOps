#!/bin/sh
##input date like : ./mkver.sh YYYY-MM-DD NUM

DATE=$1
YEAR=$(echo $DATE | cut -d - -f 1)
MOUTH=$(echo $DATE | cut -d - -f 2)
DAY=$(echo $DATE | cut -d - -f 3)
NUM=$2

if [[ $DATE == '' || $NUM == '' ]]; then
        echo "usage : ./mkver.sh YYYY-MM-DD NUM"
        exit
fi

A=$(printf "%03d\n" `echo "obase=2;$YEAR-2012"|bc`)
B=$(printf "%04d\n" `echo "obase=2;$MOUTH"|bc`)
C=$(printf "%05d\n" `echo "obase=2;$DAY"|bc`)
D=$(printf "%03d\n" `echo "obase=2;$NUM"|bc`)

echo $YEAR"-"$MOUTH"-"$DAY"-"$NUM
echo  $A"-"$B"-"$C"-"$D

E2=$A$B$C$D

((E10=2#$E2));
echo  $E10

E16=$(echo "obase=16;$E10"|bc)
echo $E16




