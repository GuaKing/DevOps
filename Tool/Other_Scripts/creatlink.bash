#!/bin/sh
VERSION=$1

if [ -z $VERSION ]; then
	echo "usage;"
	echo "./createlink.sh \$VERSION"
	echo "./createlink.sh x.x.x-x"
	echo "Note!!"
	echo "The Current DIR is $PWD"
	echo "Make sure the target dir is exist: ../$VERSION/$EsxiVERSION"
	exit 0
fi

echo "the Current DIR is $PWD"

CREATELINK()
{
	VERSION=$1
	EsxiVERSION=$2
	echo "Creating $VERSION EsxiVERSION"
	ln -s ../$VERSION/$EsxiVERSION $VERSION-$EsxiVERSION
}

CREATELINK $VERSION Esxi6.7
CREATELINK $VERSION Esxi7.0
echo "done.."


