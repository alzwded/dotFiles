#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"
STRICTLYWORDS=0
F="$( realpath "$1" )"
T=$(mktemp)
echo 'word,file' > $T
trap 'rm -f $T' EXIT
if [[ $STRICTLYWORDS -eq 1 ]] ; then
    for w in $( tr -s '[[:punct:][:space:]]' '\n' < "$F" ) ; do
        echo "$w,$F" >> $T
    done
else
    for w in $( tr -sC '[a-zA-Z0-9_\-]' '\n' < "$F" ) ; do
        echo "$w,$F" >> $T
    done
fi
sqlite3 "$DB" <<EOT
.bail off
.separator ,
.import $T data
--select count(*) from data;
EOT
#sync -f "$DB"
