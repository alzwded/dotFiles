#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"

showhelp() {
    echo "Usage: $0 w|e|f word"
    echo ""
    echo "    w         print files containing this word"
    echo "    e         print lines containing this word"
    echo "    f         print files whose path matches word"
    echo ""
    echo "Glob patterns (*,?) are accepted"
    exit 2
}

THING="$2"
THING="${THING//_/@_}"
THING="${THING//\*/%}"
THING="${THING//\?/_}"

case $1 in
    *h) showhelp ;;
    e)
        IFS='
'
        for l in $(sqlite3 "$DB" "select word,file from data where word like '$THING' escape '@'") ; do
            W=$( echo "$l" | awk -F '|' '{print $1}' )
            F=$( echo "$l" | awk -F '|' '{print $2}' )
            grep -Hn "$W" "$F"
        done
        ;;
    w)
        sqlite3 "$DB" "select file from data where word like '$THING' escape '@'"
        ;;
    f)
        sqlite3 "$DB" 'select distinct file from data where file like "%'"$THING"'%";'
        ;;
esac
