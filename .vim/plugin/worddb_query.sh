#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"

if [[ $1 == w ]] ; then
    IFS='
'
    THING="$2"
    THING="${THING//_/@_}"
    for l in $(sqlite3 "$DB" "select word,file from data where word like '$2' escape '@'") ; do
        W=$( echo "$l" | awk -F '|' '{print $1}' )
        F=$( echo "$l" | awk -F '|' '{print $2}' )
        grep -Hn "$W" "$F"
    done
elif [[ $1 == f ]] ; then
    sqlite3 "$DB" 'select distinct file from data where file like "%'"$2"'%";'
fi
