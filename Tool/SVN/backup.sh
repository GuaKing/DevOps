#!/bin/sh
Depot=$1
Date=`date +%Y%m%d%H%M`
Log=${Depot}_${Date}.log
Depot_Path="/var/svn/svn_dir"
Back_Path="/backup"
mkdir -p /backup/log 
if [ -z ${Depot} ];
then
echo "error:no depot : usage:./xx.sh Depot_name"
exit -1
fi
 
echo "depot : ${Depot_Path}/${Depot} "  >>/backup/log/${Log} 2>&1
echo "version:"  >>/backup/log/${Log} 2>&1
svnlook youngest ${Depot_Path}/${Depot}  >>/backup/log/${Log} 2>&1
 
echo "sync ing....."  >>/backup/log/${Log} 2>&1
svnadmin hotcopy ${Depot_Path}/${Depot} ${Back_Path}/${Depot}_bak --clean-logs --incremental >>/backup/log/${Log} 2>&1
echo "sync done."  >>/backup/log/${Log} 2>&1
 
echo "depot : ${Back_Path}/${Depot}_bak "  >>/backup/log/${Log} 2>&1
echo "version:"  >>/backup/log/${Log} 2>&1
svnlook youngest ${Back_Path}/${Depot}_bak >>/backup/log/${Log} 2>&1
