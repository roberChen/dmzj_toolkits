#!/bin/bash

url=""

if [[ $# == 2 && $1 == "-s" ]]; then
	url="http://manhua.dmzj.com/$2"
else
	url=$1
fi

curl $url  2>/dev/null | grep 'id="comic_id"' | sed  's/<.*>\([0-9]*\)<.*>/\1/g'
