#!/bin/sh

P_token=$TOKEN
TITLE=${TITLE}
S_branch=$Branch1
T_branch=$Branch2
SCR_DIR=$0
Location=${SCR_DIR%/*}


#grep  'http' $FILE > ${Location}/../mergePR.txt
Source_DIR=${Location}/../API_for_GITLAB
echo Source_DIR=$Source_DIR
source $Source_DIR/gitAPI_process.sh
for i in $ProjectList
do
    creat_mr $P_token $i "${TITLE}" $S_branch $T_branch
    merge_use_MR $P_token $Project_ID $MR_ID
    echo "---------------------------------------------"
    echo $i
    echo Project_ID=$Project_ID
    echo MR_ID=$MR_ID
    echo "---------------------------------------------"
    echo $merge_state
    echo "---------------------------------------------"

done

