#!/usr/bin/sh
RN=$1
PR_token=$2
PROJECT_HTTPS_URL=$3
EXE_DIR=$PWD
Script=$0
Script_DIR=${Script%/*}

## for Pre-Check
source $Script_DIR/ErrMessage.sh
if [ $# -ne 3 ]; then
	Massage=" Usage: $0 \${RELEASE_NOTE_FULL_PATH} \${PR_token} \${PROJECT_HTTPS_URL} "
	Error_Message "$Massage"
fi
if [[ $1 =~ "/" ]]; then
	if [ ! -f $1 ]; then
		Massage=" Please check the file path,File is not exist! "
		Error_Message "$Massage"
	else
		continue
	fi
else
	Massage=" Please give a full path of release note file! "
	Error_Message "$Massage"
fi

## process by API
source $Script_DIR/gitAPI_info.sh
getProIDfromName $PR_token $PROJECT_HTTPS_URL
fileName=${RN##*/}
cat $RN | sed -n '/Description/,$p'|sed -n '{2,$p}'|awk -F'[,]' '{ for(i=2; i<=4; i++) { $i="" };print $0 }' | awk -F"    *" '{print $1","$2}' >$EXE_DIR/withMR_$fileName
cat $EXE_DIR/withMR_$fileName |awk 'BEGIN {FS=","} {if($2!~/'[0-9]\{4,7\}'/)  print $0}' >$EXE_DIR/FIX_list.csv
cat  $EXE_DIR/FIX_list.csv | while read i
do
	HashID=$(echo $i|awk 'BEGIN {FS=","}{print $1}')
	getMRforCommit $PR_token $Project_ID $HashID
	MR_URL_ALl=""
	n=1
	for j in $MR_ID
	do
		MR_URL="${Project_Prefix}/merge_requests/$j"
		MR_URL_ALl="$MR_URL_ALl$n. $MR_URL "
		n=`expr $n + 1`
	done
	p=$i"("$MR_URL_ALl")"
	sed -i "/$i/c\\$p" $EXE_DIR/withMR_$fileName
done

echo -e "\n"
echo "Show info with Merge Request ID"
cat $EXE_DIR/withMR_$fileName |awk 'BEGIN {FS=","} {print$2}'|sed 's/"*$//'|sed 's/^"*//'|awk '{print NR". "$0}'
echo -e "\n"

rm -f $EXE_DIR/FIX_list.csv $EXE_DIR/withMR_$fileName
