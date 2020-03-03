#!/bin/bash

SPECIFIC=false
SPECIFIC_TAG=""



for id in {0..30000}; do
	out=$(curl $(printf "http://v3api.dmzj.com/comic/comic_%d.json" $id) 2>/dev/null | jq . 2>/dev/null )
	if [[ $? != 0 ]]; then
		printf "Fetch content of id %6d falied: not json\n" $id
	else
		name=$(echo $out | jq .title 2>/dev/null)
		ifhidden=$(echo $out | jq .hidden 2>/dev/null)
		tag=$(echo $out | jq .types[].tag_name 2>/dev/null | sed 's/"//g')
		if [[  $name == "" || $name == "null" ]]; then
			printf "Fetch content of id %6d failed: no title found\n" $id
		elif [[ $(echo $tag | grep 百合) != "" && $ifhidden == 1 ]]; then
			printf "id:%6.6d\thidden:%d\tname:%s\ttype:%s\n" $id $ifhidden "$(echo $name | sed 's/"//g')" "$(echo $tag| sed 's/ /,/g')" | tee -a bh.dmzj.scan | tee -a dmzj.com
		else
			printf "id:%6.6d\tname:%s\ttag:%s\n" $id "$(echo $name | sed 's/"//g')" "$(echo $tag | sed 's/ /,/g')" | tee -a dmzj.scan	
		fi
	fi
done

#getSpecific() {
#	if [[ $# == 1 ]];then
#		return
#	fi
#	
#	case $2 in 
#	-t|--tag)
#		shift # pop the -t or --tag parameter and 
#	;;
#}
