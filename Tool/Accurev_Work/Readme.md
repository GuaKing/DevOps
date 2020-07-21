## acwk_modify.xml

</br>

```
## Change issue context in AccuWork with xml
## acwk_modify.xml template has set issue XXX 's assign to a special user ID .
## put issue id to this xml , exec this xml , this issue will assign to the one set in acwk_modify.xml
sed "s/XXX/${ISSUE_ID}/" /vob/LTE_RELEASE/ACwork/acwk_modify.xml  > /tmp/modify${ISSUE_ID}.xml
accurev xml -l /tmp/modify${ISSUE_ID}.xml
rm /tmp/modify${ISSUE_ID}.xml

```
