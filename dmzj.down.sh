#!/bin/bash

ID=0
IFLIST=false
IFDOWN=false
DOWNID=""
DOWNALL=false
FIRSTLETTER=""

MAIN_PID=$$

isNotNum() {
	if [[ $# == 0 ]]; then
		return 2
	fi
	if [ -n "$(echo $1 | sed '/^[0-9][0-9]*$/d')" ]; then
		return 0
	fi
	return 1
}

getParams(){
	if [[ $# == 0 ]]; then
		printf 'Message: id needed\n'
		exit 0
	fi
	
	while (( $# >= 1 ))
	do
			case $1 in 
			-i | --id )
				#Get id of manga
				shift
				ID=$1
				if [[ $ID == "" ]]; then
					printf 'Error: ID empty'
				# elif [ -n "$(echo $ID | sed '/^[0-9][0-9]*$/d')" ]; then
				elif isNotNum $ID; then
					printf "Error: ID \`%s' not number\n" $ID
					exit 1
				fi
				shift
			;;
			-l | --list )
				#List contents
				IFLIST=true
				shift
			;;
			-I | --chapter-id )
				#Get the id of chapters for downloading
				shift
				if [[ $1 == "all" ]]; then
					DOWNALL=true
				fi
				DOWNID=$@
				break
			;;
			-f | --first-letter)
				#Get first letter
				shift
				FIRSTLETTER=$1
				shift
			;;
			*)
				echo Unknown param:$1
				shift
			;;
		esac
	done
	if [[ $IFLIST == false ]]; then
		IFDOWN=true
	fi
}


DownLink() {
	F=$1 #first letter
	ID=$2
	index=$3
	printf "Downloading: ID %6d,\tchapter id:%6d\n" $ID $index
	wget -c "http://images.dmzj.com/$F/$ID/$index.zip" --header Host:imgzip.dmzj.com	
}

CharacterLen() {
	chnum=$(($(echo $1 | wc -m ) -1))
	chlen=$(($(echo $1 | wc -c ) -1))
	zhnum=$(( ($chlen - $chnum) /2 ))
	ennum=$(( $chnum - $zhnum ))
	echo $(( $zhnum*2 + $ennum ))
}

printInfo() {
	json=$1
	if [[ $# == 2 && $2 == "json" ]]; then
		echo $json | jq .
		return
	fi
	ifhidden=$(echo $json | jq '.hidden' )
	is_lock=$(echo $json | jq '.is_lock')
	first_letter=$(echo $json | jq '.first_letter')
	comic_py=$(echo $json | jq '.comic_py')
	name=$(echo $json| jq '.title')
	ID=$(echo $json | jq '.id')
	length=$(echo $json | jq '[.chapters[0].data[]] | length' )
	if [[ $ifhidden == 1 || $is_lock == 1 ]]; then
		printf "\033[43;91mWARNNING\033[0m\033[33m This Comic is hiddeen or locked by 动漫之家, please  get comic info at night!(Around 20 o'clock at night)\033[0m\n"
	fi
	namelength=$(( $(CharacterLen $name) + 20))
	printf "\033[32m        NAME\033[0m %*s\t\033[32m          ID\033[0m %s\n" $namelength $name $ID
	printf "\033[32m LOCK STATUS\033[0m %*d\t\033[32m HIDE STATUS\033[0m %s\n" $namelength $is_lock $ifhidden
	printf "\033[32mCOMIC STRING\033[0m %*s\t\033[32mFIRST LETTER\033[0m %s\n" $namelength $comic_py $first_letter
	printf "%5s\t%s\n" id name
	echo $json | jq '.chapters[0].data[] | [(.chapter_id|tostring),.chapter_title] | join(" ")' |
			 sed -e $'s/"//g 
				s/ /\t/g' | sort	
	printf "\033[33mtotal\033[0m:%d\n" $length
}

getFirstLetter() {
	json=$1
	echo $json | jq '.first_letter' | sed 's/"//g'
}

getJsInfo() {
	ID=$1
	if isNotNum $ID ; then
		echo "ID ($ID) not num"
		exit 1
	fi
	res=$(curl "http://v3api.dmzj.com/comic/comic_$ID.json" 2>/dev/null)
	if [[ ! $(echo $res | jq . 2>/dev/null) ]]; then
		printf "\033[32mERROR: Not a json file\033[0m: %s\n", $res
 		kill -s TERM $MAIN_PID
	fi
	echo $res
}

getAllIndex() {
	json=$1
	echo $json | jq '.chapters[0].data[] | [.chapter_id | tostring] | join(" ")' | sed 's/"//g'
}


getParams $@
trap 'exit 1' TERM

echo id: $ID

if [[ $IFLIST == true ]]; then
	echo listing
	printInfo $(getJsInfo $ID)
elif [[ $IFDOWN == true ]]; then
	echo downloading
	js=""
	if [[ $FIRSTLETTER == ""  ]]; then
		js=$(getJsInfo $ID)
		FIRSTLETTER=$(getFirstLetter $js)
		printf "Using first letter: \`%s'\n" $FIRSTLETTER
	fi
	if [[ $DOWNALL == true ]]; then
		echo downloads all
		if [[ $js == "" ]]; then
			js=$(getJsInfo $ID)
		fi
		for id in $(getAllIndex $js)
		do
			DownLink $FIRSTLETTER $ID $id	
		done	
	else
		echo downloads: $DOWNID
		for id in $DOWNID
		do
			DownLink $FIRSTLETTER $ID $id
		done
	fi
fi
