#!/bin/bash
WSP_DIR=$1

cd ${WSP_DIR}
mkdir temp 
while read line           
do           
    cp ${WSP_DIR}/unix/${line} temp/
done < ~/jk_scripts/$2/templist_unix.txt 

while read line2
do
    cp ${WSP_DIR}/unix/linux.obj/${line2} temp/
done < ~/jk_scripts/$2/templist_linux.txt

tar cvf temp.tar temp
rm -rf temp
