#!/usr/bin/sh

if [ $Include_MergeRequest == false ]; then
    Flag="--no-merges"
fi
for i in ${projectList}
do
    echo  "-------------------------------"
    echo $i
    echo "show which commits $Branch1 has ，$Branch2 does not has"
	git clone https://$USER:$PASS@${i##*://} >/dev/null 2>&1
    cd $(echo ${i##*/} | cut -d . -f 1)
    count=$(git log origin/$Branch1 ^origin/$Branch2 --oneline $Flag|wc -l)
    echo "$count commits"
    if [ $count != 0 ]; then
        echo "$i($count)" >>../commits.txt
        git log origin/$Branch1 ^origin/$Branch2 --pretty=format:"%cd %cn %s" $Flag>>../commits.txt
        echo -e "\n" >>../commits.txt
    fi
    cd ..
    
done
echo -e "\n"
echo "------------------------------------------------------------------------------------------"
echo "Below are all the projects which has commits in $Branch1 (not merge to $Branch2 yet) "
echo "------------------------------------------------------------------------------------------"
if [ -f commits.txt ]; then
    cat commits.txt
else
    echo "NO Commits $Flag"
fi
echo "----------------------------------------------------------------------------------------"
echo "Above are the commits info collected at"  $(date +"%Y-%m-%d  %H:%M:%H") 
echo "----------------------------------------------------------------------------------------"