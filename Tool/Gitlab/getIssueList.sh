#!/usr/bin/sh

############################# USAGE EXAMPLE #############################

### Status=opened
### Key="iid state labels assignees[].name author.name title web_url"
### Key_NAME="issue ID,STATUS,LABELS,ASSIGINESS,REPORTER,TITLE,ISSUE URL"

### for i in $PROJECT_HTTPS_URLs
### do
### ./getIssueList.sh $Token $i $Status "$Key" "$Key_NAME"
### done

############################# USAGE EXAMPLE #############################




PR_token=$1
PROJECT_HTTPS_URL=$2
Status=$3
Key=$4
Key_NAME=$5


EXE_DIR=$PWD
Script=$0
Script_DIR=${Script%/*}

## for Pre-Check
source $Script_DIR/ErrMessage.sh
if [ $# -ne 5 ]; then
        Massage=" Usage: $0 \${RELEASE_NOTE_FULL_PATH} \${PR_token} \${PROJECT_HTTPS_URL} "
        Massage=" Usage: $0 \${RELEASE_NOTE_FULL_PATH} \${PR_token} \${PROJECT_HTTPS_URL} "
        Error_Message "$Massage"
fi


## process by API
source $Script_DIR/gitAPI_info.sh
getProIDfromName $PR_token $PROJECT_HTTPS_URL
file_Name=$(echo $Name_with_namespace |sed 's/%2F/_/g').csv
#echo $file_Name
#echo $Project_ID
#Status=all
#Key="iid state labels assignees[].name author.name title web_url"
#Key_NAME="issue ID,STATUS,LABELS,ASSIGINESS,REPORTER,TITLE,ISSUE URL"


List_project_ISSUE_CVS $PR_token $Project_ID $Status "$Key" "$Key_NAME"