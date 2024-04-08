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
GREPTHING="$2"

THING="${THING//_/@_}"
THING="${THING//\*/%}"
THING="${THING//\?/_}"

GREPTHING="${GREPTHING//\*/.*}"
GREPTHING="${GREPTHING//\?/.?}"

case $1 in
    *h) showhelp ;;
    e)
        IFS='
'
        for F in $(sqlite3 "$DB" "select file from refs where word in ( select id from words where word like '$THING' escape '@' )") ; do
            grep -Hn "$GREPTHING" "$F"
        done
        ;;
    w)
        sqlite3 "$DB" "select file from refs where word in ( select id from words where word like '$THING' escape '@' )"
        ;;
    f)
        sqlite3 "$DB" 'select distinct file from refs where file like "%'"$THING"'%";'
        ;;
esac
