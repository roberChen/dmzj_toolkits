#!/bin/bash

SPECIFIC=false
SPECIFIC_TAG=""
STARTID=1
ENDID=30000
getSpecific() {
	while (( $# >= 1 ))
		do
			case $1 in 
				-t| --tag)
					shift
					SPECIFIC=true
					shift
					SPECIFIC_TAG=$1
					;;
				-i| --id)
					shift
					STARTID=$1
					if [ -z "${STARTID%[0-9]*}" ] || (( $STARTID < 0 )); then
						echo Invalid STARTID
						exit
					fi
					shift
					;;
				-e| --end)
					shift
					ENDID=$1
					if [ -z "${ENDID%[0-9]*}" ] || (( $ENDID < 0 )); then
						echo Invalid ENDID
						exit
					fi
					shift
					;;

			esac
		done
}

getSpecific $@

for id in $(seq $STARTID $ENDID); do
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

