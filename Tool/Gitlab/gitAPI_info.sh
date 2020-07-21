#!/usr/bin/sh

## https://docs.gitlab.com/ee/api/v3_to_v4.html
API_VERSION=v4
GITLAB_INSTANCE=https://gitlab.xxxxxx.com


SubjectFormat()
{
    Subject=$1
    L=$(echo ${#Subject})
    str=$(printf "%-${L}s" "-")
    echo "${str// /-}"
    echo  $Subject
    echo "${str// /-}"
}

RowFormat()
{
    sep=@y
    echo $1$sep$2 >tmp
    awk -F "$sep" '{printf "%-15s%-15s\n",$1,$2}' tmp
    rm tmp
}

Show_with_multiKey()
{
    JSON_Object=$1
    KEY=$2
    arrays_Count=$(jq 'arrays|length' ${JSON_Object})
    if [[ $arrays_Count != "" ]]; then
        ref="[]."
        in_array="arrays[0]|"
    fi
    for j in $KEY
    do
        k=$(echo $j | cut -d "[" -f 1| cut -d "." -f 1)
        flag=$(jq "${in_array}has(\"$k\")" ${JSON_Object})
        if [ $flag == "true" ]; then
            v=$(jq ".$ref$j" ${JSON_Object})
            RowFormat  $k $v
        fi
    done
    echo -e "\n"
}

getProIDfromName()
{
    
    P_token=$1
    PROJECT_HTTPS_URL=$2
    Namespace=$(echo ${PROJECT_HTTPS_URL##*//})
    Namespace=${Namespace%/*}
    Namespace=${Namespace#*/}
    Namespace=$(echo $Namespace |sed 's/\//%2F/g')
    ProjectNamge=$(echo ${PROJECT_HTTPS_URL##*/}|cut -d . -f1)
    Name_with_namespace="${Namespace}%2F${ProjectNamge}"
    getProIDfromName_JSON=$(curl --header "PRIVATE-TOKEN: $P_token" $GITLAB_INSTANCE/api/$API_VERSION/projects/${Name_with_namespace} -k 2>/dev/null) 
    Project_ID=$(echo $getProIDfromName_JSON|jq '.id')
    Project_url=$(echo $getProIDfromName_JSON|jq '.http_url_to_repo')
    Project_Prefix=${GITLAB_INSTANCE}/${Namespace}/${ProjectNamge}
    #echo ${Project_ID}   ${Project_url}
}

getMRforCommit()
{
    P_token=$1
    Project_ID=$2
    HashID=$3
    MRKey="web_url"
    curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/repository/commits/${HashID}/merge_requests -k  2>/dev/null >getMRforCommit.json
    MR_ID=$(cat getMRforCommit.json| jq '.[].iid')
    rm -f getMRforCommit.json
    SubjectFormat "HashID : $HashID"
    SubjectFormat "MR ID : $MR_ID"
}

Single_issue()
{
    P_token=$1
    Project_ID=$2
    ISSUE_ID=$3
    Key=$4
    # Key eg: "state iid title assignees[].username web_url"
    curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/issues/${ISSUE_ID} -k 2>/dev/null >Single_issue.json
    SubjectFormat "ISSUE_ID : $ISSUE_ID"
    Show_with_multiKey Single_issue.json "$Key"
    rm Single_issue.json 
}

Single_MR()
{
    P_token=$1
    Project_ID=$2
    MR_ID=$3
    Key=$4
    curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/merge_requests/${MR_ID} -k 2>/dev/null >Single_MR.json
    
    SubjectFormat "MR ID : $MR_ID"
    Show_with_multiKey Single_MR.json "$Key"
    rm Single_MR.json
}

List_project_ISSUE()
{
    P_token=$1
    Project_ID=$2
    # Status :opened closed all
    Status=$3
    Key=$4
    List_project_ISSUE_JSON=$(curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/issues?state=${Status} -k 2>/dev/null)
    ISSUE_ID=$(echo $List_project_ISSUE_JSON | jq '.[].iid')
    echo "All issue with Status=$Status in project_$Project_ID are below : count = $(echo $ISSUE_ID|wc -w)"
    echo $ISSUE_ID
    for i in $ISSUE_ID
    do
        Single_issue $P_token $Project_ID $i "$Key"
    done
}

List_merge_requests_related_to_issue()
{
    P_token=$1
    Project_ID=$2
    ISSUE_ID=$3
    MRKey="iid state title assignees[].username web_url source_branch target_branch"
    List_issues_MR_JSON=$(curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/v4/projects/${Project_ID}/issues/${ISSUE_ID}/related_merge_requests -k 2>/dev/null)
    MR_ID=$(echo $List_issues_MR_JSON | jq '.[].iid')
    count=$(echo $MR_ID|wc -w)
    Single_issue  $P_token $Project_ID $ISSUE_ID "web_url"
    echo "All MR with ISSUE_ID=$ISSUE_ID in project_$Project_ID are below :"
    for ((i=1; i <= $count; i++));
    do
        echo -e "$i. \c"
        echo $MR_ID| awk -F"  *" '{print $'$i'}'
    done
    echo -e "\n"
    for i in $MR_ID
    do
        Single_MR $P_token $Project_ID $i "$MRKey"
    done

}

List_project_MR()
{
    P_token=$1
    Project_ID=$2
    # Status :opened closed all merged
    Status=$3
    Key=$4
    List_project_MR_JSON=$(curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/merge_requests?state=${Status} -k 2>/dev/null)
    
    MR_ID=$(echo $List_project_MR_JSON | jq '.[].iid')
    echo "All MR with Status=$Status in project_$Project_ID are below : count = $(echo $MR_ID|wc -w)"
    echo $MR_ID
    
    for i in $MR_ID
    do
        Single_MR $P_token $Project_ID $i "$Key"
    done
}


Show_in_CSV()
{
    JSON_Object=$1
    KEY=$2
    Line=""
    arrays_Count=$(jq 'arrays|length' ${JSON_Object})
    if [[ $arrays_Count != "" ]]; then
        ref="[]."
        in_array="arrays[0]|"
    fi
    for j in $KEY
    do
        k=$(echo $j | cut -d "[" -f 1| cut -d "." -f 1)
        flag=$(jq "${in_array}has(\"$k\")" ${JSON_Object})
        if [ $flag == "true" ]; then
            v=$(jq ".$ref$j" ${JSON_Object})
            if [ $k == "labels" ]; then
                tmp=$(echo $v| tr ',' ';'|tr '[' ' '|tr ']' ' ')
                v=$tmp
            fi
            Line="$Line$v,"
        fi
    done
    echo $Line>>$file_Name
}

Single_issue_CVS()
{
    P_token=$1
    Project_ID=$2
    ISSUE_ID=$3
    Key=$4
    # Key eg: "state iid title assignees[].username web_url"
    curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/issues/${ISSUE_ID} -k 2>/dev/null >Single_issue.json
    Show_in_CSV Single_issue.json "$Key"
    rm Single_issue.json 
}

Open_Issue_Count()
{
    #"open_issues_count":88
    P_token=$1
    Project_ID=$2
    # Status :opened closed all merged

    List_project_JSON=$(curl --header "PRIVATE-TOKEN: $P_token" ${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID} -k 2>/dev/null)
    
    Open_count=$(echo $List_project_JSON | jq '.open_issues_count')
    echo $Open_count >${Project_ID}_open_issues_count.txt
    cat ${Project_ID}_open_issues_count.txt
}

List_project_ISSUE_CVS()
{
    P_token=$1
    Project_ID=$2
    # Status :opened closed all
    Status=$3
    Key=$4
    Key_NAME=$5
    PER_PAGE=100
    LsitprojectissueFile=List_project_${Project_ID}_ISSUE.json
    PAGES=2
    if [ $Status == "opened" ]; then
        Open_Issue_Count $P_token $Project_ID
        IF_Zero=`expr $(cat ${Project_ID}_open_issues_count.txt) % $PER_PAGE`
        ORG_PAGES=`expr $(cat ${Project_ID}_open_issues_count.txt) / $PER_PAGE`
        if [ ${IF_Zero} -eq 0 ]; then
            PAGES=$ORG_PAGES
        else
            PAGES=`expr $ORG_PAGES + 1`
        fi
        rm -f ${Project_ID}_open_issues_count.txt
    fi

    rm -f $LsitprojectissueFile
    for i in $( seq 1 $PAGES)
    do
        curl --header "PRIVATE-TOKEN: $P_token" "${GITLAB_INSTANCE}/api/${API_VERSION}/projects/${Project_ID}/issues?state=$Status&per_page=$PER_PAGE&page=$i" -k 2>/dev/null >>$LsitprojectissueFile
    done

    ISSUE_ID=$(cat $LsitprojectissueFile | jq '.[].iid')
    count=$(echo $ISSUE_ID|wc -w)
    echo "All issue with Status=$Status in project_$Project_ID are below : count = $count"
    if [ $count -eq 0 ]; then
        echo "NO ISSUE in THIS PROJECT"
    else
        echo $ISSUE_ID
        echo "$Key"
        rm -f $file_Name
        echo "$Key_NAME">>$file_Name
        for i in $ISSUE_ID
        do
            Single_issue_CVS $P_token $Project_ID $i "$Key"
        done
    fi
    rm -f $LsitprojectissueFile
}

