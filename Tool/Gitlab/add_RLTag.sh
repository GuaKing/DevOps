#!/usr/bin/sh

# P_token=
# TAG_NAME=
# Message=
# TagCommit=
# RELEASE_NOTE=
# Above are given in jenkins http://xxxxxxx


Script=$0
Script_DIR=${Script%/*}
gitRootDir=${Script_DIR}/..


if [ -n ${RELEASE_NOTE} ]; then

    if [ -n ${TagCommit} ]; then
        echo "${RELEASE_NOTE} is given , use release note instead of Tagcommit context"
    fi
    
    TagCommit=$(cat ${RELEASE_NOTE} | grep -e "^[a-z|-]\{1,\}:[a-z|0-9]\{1,\}$")
fi
    
for i in ${TagCommit}
do
    echo $i
    project=$(echo ${i} | cut -d : -f 1)
    PROJECT_HTTPS_URL=https://gitlab.xxxxx.com/vmc/${project}.git
    commit=$(echo ${i} | cut -d : -f 2)
    Message_NEW=$(echo $Message | tr " " "_")
    echo "project url is ${PROJECT_HTTPS_URL}"	
	source $gitRootDir/API_for_GITLAB/gitAPI_process.sh
    Create_Tag $P_token $PROJECT_HTTPS_URL $TAG_NAME $commit $Message_NEW
done