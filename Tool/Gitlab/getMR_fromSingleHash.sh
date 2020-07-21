#!/usr/bin/sh

P_token=$1
PROJECT_HTTPS_URL=$2
HashID=$3
Script=$0
Script_DIR=${Script%/*}

source $Script_DIR/gitAPI_info.sh
getProIDfromName $P_token $PROJECT_HTTPS_URL
echo $Project_Prefix
echo "getMRforCommit $P_token $Project_ID $HashID"
getMRforCommit $P_token $Project_ID $HashID

MR_URL_ALl=""
n=1
for j in $MR_ID
do
	MR_URL="${Project_Prefix}/merge_requests/$j"
	echo "$n. $MR_URL"
	n=`expr $n + 1`
done
