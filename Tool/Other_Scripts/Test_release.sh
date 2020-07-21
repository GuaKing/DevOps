#!/bin/sh
# update the project
Release_dir="/temp/TEST/${BRANCH}"
PACK_NAME=TEST_${VERSION}.tar
VERSIONFILE=TEST_${VERSION}_VERSION_INFO.txt
Prev_build=$(cat $Release_dir/MAP/TEST_${PREV_VERSION}_VERSION_INFO.txt| grep HASH_ID |cut -d = -f 2)
echo "Prev_build is ${Prev_build}"
cd ~/TEST

git pull
echo "git checkout $BRANCH"
git checkout $BRANCH
git pull 

Prev_build=$(echo ${Prev_build}|sed 's/[ \t]*$//')
# get the Current commit number : the newest hash value
Cur_Build=`git log --pretty=format:"%h" | head -n 1`
mkdir -p $WORKSPACE/prop
echo "VERSION=$VERSION" >$WORKSPACE/prop/args.prop
echo "BRANCH=${BRANCH}" >>$WORKSPACE/prop/args.prop
echo "PREV_VERSION=$PREV_VERSION" >$WORKSPACE/prop/args.prop
cat $WORKSPACE/prop/args.prop

git log --pretty=format:"%h" -n 100 >temp.txt
if [ $(grep -q ${Prev_build} temp.txt;echo $?) -ne 0 ]; then
    rm -f temp.txt
    echo "Error:no commit Prev_build:${Prev_build} in the current branch $BRANCH !"
    exit -1
fi    

if [ ${Cur_Build} == ${Prev_build} ]; then
	echo "Cur_Build: ${Cur_Build} == Prev_build: ${Prev_build}"
    echo "no commit since previous build !"
    exit -1
fi

# --------------------------------------------------------------------------------------------------
# deal with the parameter of TEST_to_Include
Release_note="TEST_${VERSION}_release_note.txt"
echo $TEST_to_Include | tr ',' '\n'|sed 's/[ \t]*$//' |sed 's/^[ \t]*//' >test_to_include.txt
echo $TEST_to_Include | tr ',' ' ' >test_package.txt

# package the TEST.tar with the TEST_to_Include list
tar cvf ${PACK_NAME} $(cat test_package.txt)

# the release note processer : get the commits list from Prev_build to Cur_Build
# temp-change.txt
git log  ${Cur_Build} ^${Prev_build} --pretty=format:"%h %s" --no-merges | cat -n >temp-change.txt
echo -e "\n" >>temp-change.txt


# the release note processer : get the git project info in this build
# temp1.txt
echo -e "\n
TEST Version: ${VERSION}

Jenkins INFO:
JOB_URL : ${JOB_URL}
BUILD_URL :${BUILD_URL}

GitLab INFO:
GIT PROJECT: http://xxxxxxxxxxTEST.git
GitLab BRANCH: $BRANCH

RELEASE DIR : ${Release_dir}/${VERSION}

The note shows changes between $Prev_build-${Cur_Build} 
\n " >temp1.txt

# the release note processer : get the init-TEST include in this build
# temp2.txt

echo -e "\nCompare with prev-build ${Prev_build}, these TEST have been modified : " >temp2.txt
cat test_to_include.txt >>temp2.txt

# the release note processer : get the folder name which change from Prev_build to Cur_Build
# temp3.txt ,use to modify temp2.txt
git diff  ${Prev_build} ${Cur_Build} --name-only  |cut -d / -f 1 | sort -u >temp3.txt

# the release note processer : mark the change tag behind the test's name 
# temp2.txt
count=0
for p in $(cat test_to_include.txt)
do
    if [ $count -ne 0 ]; then
		exp=$exp" || "
	fi
	str="\${i} == ${p}"
	exp=$exp$str
	#echo $exp //debug
	count=`expr $count + 1`
done
change_list=`cat temp3.txt `
for i in ${change_list}
do
	if [[ $exp ]]; then 
        sed -i "/${i}/c\\${i} <-- change" temp2.txt
    fi
done

# the release note processer : put all parts together
cat temp1.txt temp-change.txt temp2.txt >$Release_note
echo -e >>$Release_note


if [ $allowRebuild == "true" ]; then
    echo "enter allowrebuild"
    rm -rf $Release_dir/MAP/$VERSIONFILE
    rm -rf $Release_dir/$VERSION/*
fi

Generate_MAP()
{

echo "VERSION=$VERSION">$VERSIONFILE
echo "BRANCH=$BRANCH">>$VERSIONFILE
echo "HASH_ID=$Cur_Build">>$VERSIONFILE
mv $VERSIONFILE  $Release_dir/MAP/
}
# default allowRebuild=false ,it is set in jenkins project - config .


if [ -f $Release_dir/MAP/$VERSIONFILE ]; then
    echo "error: the same version has been there ,can't overwrite"
    echo "If you are sure to re-build with the same version number,Please check the checkbox 'allowRebuild' in the build page!"
    exit -1
else
    Generate_MAP  
fi

# copy the tar and note to the release dir
mkdir -p $Release_dir/$VERSION
cp $Release_note ${PACK_NAME} $Release_dir/$VERSION
rm -f *.txt
ls -all  $Release_dir/$VERSION
cat $Release_dir/$VERSION/$Release_note

cp $Release_dir/$VERSION/$Release_note $WORKSPACE

# add VERSION_INFO txt for TEST , for record the VERSION and HASH ID
