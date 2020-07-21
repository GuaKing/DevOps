#!/bin/bash 
DIR="/public/autoAPP" 
Add_File="/public/lcf/add_file.list"
Del_File="/public/lcf/del_file.list"
Time=`date +%Y%m%d%H%M`
LogFile="/public/lcf/$Time.log"

cd  $DIR
# 判断是否有新加文件
svn st | grep "? \+" | sed "s/? \+//" |grep -v " " > $Add_File
svn st | grep "! \+" | sed "s/! \+//" |grep -v " " > $Del_File

add_num=`cat $Add_File | wc -l `
del_num=`cat $Del_File | wc -l `

echo $Time >$LogFile

if [ $add_num == 0 ];then
    echo "no file add"  >>$LogFile
else
    echo "svn add"	>>$LogFile
    # 添加所有新文件  
    cat $Add_File | xargs svn add >>$LogFile
fi

if [ $del_num == 0 ];then
	echo "no file delete" >>$LogFile
else
    echo "svn delete" >>$LogFile
    # 删除所有本地缺失的文件  
    cat $Del_File | xargs svn delete >>$LogFile
fi

# 提交
svn ci -m 'auto commit by script' --username svnmgr --password xxxxxx   >>$LogFile
rm $Add_File  $Del_File

find /public/lcf -type f -name "*log" -mtime +7 -exec rm {} \;
