#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"

showhelp() {
    echo "Usage: $0 w|e|f globpattern"
    echo "       $0 wn|en words..."
    echo ""
    echo "    w         print files containing this pattern"
    echo "    e         print lines containing this pattern"
    echo "    f         print files whose path matches pattern"
    echo "    wn        print files containing multiple words"
    echo "    we        print lines from files containing selected words"
    echo ""
    echo "The e variants prints "file:linenumber: line text"
    echo "The other variants print file names
    exit 2
}

THING="$2"
GREPTHING="$2"

GREPTHING="${GREPTHING//\*/.*}"
GREPTHING="${GREPTHING//\?/.?}"

select_multiple() {
    if [[ $# -lt 1 ]] ; then
        return
    fi

    local WORDLIST="'$1'"
    local N=$#
    local word
    shift
    for word in "$@" ; do
        WORDLIST="$WORDLIST , '$word'"
    done

    # Note to self, for wordids, you can say word glob '$1' [ or word glob '$2' ... ],
    # then check with wordcount>$N or some better expression;
    # To properly select multiple glob matches, we'd probably need separate
    # tables and make sure a fileid is in ALL tables, which is starting to get
    # quite excessive. There's probably some SQL magic sugar I'm not aware of.
    local Q="WITH
                  wordids AS (SELECT id FROM words WHERE word IN ($WORDLIST)),
                  filteredrefs AS (SELECT * FROM refs WHERE word IN wordids),
                  counts(fileid, wordcount) AS (SELECT file, COUNT(word) FROM filteredrefs GROUP BY file),
                  selectedfiles(id) AS (SELECT fileid FROM counts WHERE wordcount=$N)
             SELECT file FROM files WHERE id IN selectedfiles;"

    #echo "$Q"

    sqlite3 "$DB" "$Q"
}

case $1 in
    e)
        for F in $(IFS='
' sqlite3 "$DB" "select file from files where id in (select file from refs where word in ( select id from words where word glob '$THING' ))" ) ; do
            grep -Hn "$GREPTHING" "$F"
        done
        ;;
    w)
        sqlite3 "$DB" "select file from files where id in (select file from refs where word in ( select id from words where word glob '$THING' ))"
        ;;
    wn)
        # strip wn
        shift
        select_multiple "$@"
        ;;
    en)
        # strip wn
        shift
        printf -v POLYGREP '%s\|' "$@"
        for f in $(IFS='
' select_multiple "$@"); do
            #echo "${POLYGREP%\\|}" "$f"
            grep -Hn -e "${POLYGREP%\\|}" "$f"
        done
        ;;
    f)
        sqlite3 "$DB" 'select distinct file from files where file glob "*'"$THING"'*";'
        ;;
    *h) showhelp ;;
    *) showhelp ;;
esac
