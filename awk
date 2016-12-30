#!/bin/bash

# print the first column (first str separated by space) in file/stdout
# awk '{ print $2,$1 }' lorem.txt
# concat 
# awk '{ print $2.$1 }' lorem.txt

# regex in first column only
awk '/lorem/i {print $1}' lorem.txt
awk '{ if($1 ~ /cillum/) print }' lorem.txt

# sum columns
ps -o pmem --no-headers -e | grep chrome | awk '{ln+=$1}END{print ln}'


# print all packages installed (disregarding if were removed)
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


# # get time and pv (both output to sdterr) to log.text. Disregard rsync output.
# (time sudo rsync --info=progress2 --dry-run --delete -aAXHt --exclude={"/dev/*",
# 	"/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/var/run/*","/var/lock/*","/var/cache/apt/archives/*",
# 	"/lost+found","/home/*/.gvfs","/home/*/.cache","/home/*/.local/share/Trash",
# 	"/home/*/.thumbnails/*"} / /media/rick/test | pv -FWs 3M -i 0.1) 2> >(tee log.text >&2) >/dev/null

# # time to time.txt and pv to console and strerr.logs. Disregard rsync output.
#  sudo time 2> time.txt rsync --info=progress2 --dry-run --delete -aAXHt --exclude={"/dev/*",
#  "/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/var/run/*","/var/lock/*",
#  "/var/cache/apt/archives/*","/lost+found","/home/*/.gvfs","/home/*/.cache",
#  "/home/*/.local/share/Trash","/home/*/.thumbnails/*"} / /media/rick/test | pv -fW -s 1m >/dev/null 2> >(tee stderr.logs)

# | pv -Wfs $backup_size 2> >(cat >/dev/tty | tr '\r' '\n' | tail -n 2 > $backup_dir/rsync_backup.log) >/dev/null

# print same line output program to same line awk.
# rsync -P -a /usr/share/icons ~/Desktop/rsynctest | awk -v RS="\r" '{ printf $0"\033[K\r"}' > rs.log > /dev/tty