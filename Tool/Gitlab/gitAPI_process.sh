#!/usr/bin/sh
## https://docs.gitlab.com/ee/api/v3_to_v4.html
API_VERSION=v4
GITLAB_INSTANCE=https://gitlab.xxxxxx.com


Script=$0
Script_DIR=${Script%/*}
gitRootDir=${Script_DIR}/..
source $gitRootDir/API_for_GITLAB/gitAPI_info.sh
echo $gitRootDir
Create_Tag()
{
    P_token=$1
    PROJECT_HTTPS_URL=$2
	TAG_NAME=$3
	HASH_ID=$4
	Message=$5
	getProIDfromName $P_token $PROJECT_HTTPS_URL
	#echo Project_ID $Project_ID
    curl --request POST --header "PRIVATE-TOKEN: $P_token" "${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/repository/tags?tag_name=${TAG_NAME}&ref=${HASH_ID}&message=${Message}" -k
}

creat_mr()
{
    P_token=$1
    PROJECT_HTTPS_URL=$2
    title="$3"
    S_branch=$4
    T_branch=$5
    title=`echo $title | awk '{ gsub(/ /,"%20"); print $0 }'`

    getProIDfromName $P_token $PROJECT_HTTPS_URL
    getcreatMR_JSON=$(curl --request POST --header "PRIVATE-TOKEN: $P_token" "${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/merge_requests?title=${title}&source_branch=${S_branch}&target_branch=${T_branch}" -k 2>/dev/null)
    MR_ID=$(echo ${getcreatMR_JSON}| jq '.iid')
    #echo $MR_ID
}

update_mr()
{  
    P_token=$1
    Project_ID=$2
    MR_ID=$3
    message=$4
    update_mes=`echo $message | awk '{ gsub(/\&/,"%26"); print $0 }'`
    update_mes=$(echo $update_mes|sed 's/[;\t]/\&/g')
    update_mes=`echo $update_mes | awk '{ gsub(/ /,"%20"); print $0 }'`
    update_JSON=$(curl --request PUT --header "PRIVATE-TOKEN: $P_token" "${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/merge_requests/${MR_ID}?${update_mes}" -k 2>/dev/null)
    count=$(echo $message | tr ';' '\n' | wc -l)
    for((i=1; i<=$count; i++)) 
    do
        mes[$i]="$(echo $message| awk -F";" '{print $'$i'}')"         
        key=$(echo ${mes[i]%=*})
        echo "update_rusult:$key = $(echo ${update_JSON}| jq '.'$key'')"
    done
}

merge_use_MR()
{
    P_token=$1
    Project_ID=$2
    MR_ID=$3
    mergeuseMR_JSON=$(curl --request PUT --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/merge_requests/${MR_ID}/merge -k 2>/dev/null)
    merge_state=$(echo ${mergeuseMR_JSON}| jq '.state')
}


