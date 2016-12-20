#!/bin/bash

# print the first column (first str separated by space) in file/stdout
# awk '{ print $2,$1 }' lorem.txt
# concat 
# awk '{ print $2.$1 }' lorem.txt

# regex in first column only
awk '/lorem/i {print $1}' lorem.txt
awk '{ if($1 ~ /cillum/) print }' lorem.txt
