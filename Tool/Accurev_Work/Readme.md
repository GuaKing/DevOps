## acwk_modify.xml

```
## three args for promote command
VERSION_FILE=xx/xx/xx/xx.ml
ISSUE_ID=xxxxx
Comment="move version to $NEW_VERSION , build type:$BUILD_TYPE"

## modify what need to auto changes in target-file
version=${NEW_VERSION##*-}
sed -i "/QA=/c\QA=$version" $VERSION_FILE

## Change issue context in AccuWork with xml
## acwk_modify.xml template has set issue XXX 's assign to a special user ID .
## put issue id to this xml , exec this xml , this issue will assign to the one set in acwk_modify.xml
sed "s/XXX/${ISSUE_ID}/" /vob/LTE_RELEASE/ACwork/acwk_modify.xml  > /tmp/modify${ISSUE_ID}.xml
accurev xml -l /tmp/modify${ISSUE_ID}.xml
rm /tmp/modify${ISSUE_ID}.xml

## do a promote
accurev keep $VERSION_FILE -c "$Comment"
accurev promote $VERSION_FILE -c "$Comment"  -I $ISSUE_ID

```
