#!/bin/bash

# print the first column (first str separated by space) in file/stdout
# awk '{ print $2,$1 }' lorem.txt
# concat 
# awk '{ print $2.$1 }' lorem.txt

# regex in first column only
awk '/lorem/i {print $1}' lorem.txt
awk '{ if($1 ~ /cillum/) print }' lorem.txt



user=$1

process() { 
	awk '{$1=""; $2=""; $3=""; print}' | # removes first 3 columns
	awk '{OFS=RS;$1=$1}1' | #convert spaces to new line
	awk '!x[$0]++'  | # removes duplicates
	sort
}


# field separator is an empty line
cat /var/log/apt/history.log \
	| awk -v usr="$user" 'BEGIN{ FS="\n"; RS="" }
		{ date=$1; cmdln=$2; req=$3; action=$4; endDate=$5 }
		{ if (req ~ "Requested-By: "usr) print cmdln }' \
	| process >&1



cat /var/log/apt/history.log |
	# first command after search is executed after the lines within the pattern match is complete.
	awk -v usr="$user" '/Start/ {if (x ~ "Requested-By: "usr) print x "\n"; x=""}
		{x=(!x)? $0 : x"\n"$0 } 	# here you can process each line represented with $0
		END{ print x}' |	# neccesary since the last first command wont execute
	awk 'BEGIN{FS="\n"; RS=""} {print $2}' \
	| process >&1

