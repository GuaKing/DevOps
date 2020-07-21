#!/usr/bin/sh

Error_Message()
{
	Message=$1
	L=$(echo ${#Message})
	str=$(printf "%-${L}s" "#")
	echo "${str// /#}"
	echo  $Massage
	echo "${str// /#}"
	exit
}
