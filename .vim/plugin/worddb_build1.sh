#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"
STRICTLYWORDS=0
F="$( realpath "$1" )"
T=$(mktemp)
echo 'BEGIN TRANSACTION;' > $T
trap 'rm -f $T' EXIT
if [[ $STRICTLYWORDS -eq 1 ]] ; then
    for w in $( tr -s '[[:punct:][:space:]]' '\n' < "$F" ) ; do
        echo "$w,$F" >> $T
    done
else
    # can't decide how wise it is to include -
    # maybe s/^-*(.*)-*$/\1/ at the end? For later
    #for w in $( tr -sC '[a-zA-Z0-9_\-]' '\n' < "$F" ) ; do
    for w in $( tr -sC '[a-zA-Z0-9_]' '\n' < "$F" ) ; do
        echo "INSERT OR IGNORE INTO words(word) VALUES ('$w');" >> $T
        echo "INSERT OR IGNORE INTO files(file) VALUES ('$F');" >> $T
        echo "INSERT OR IGNORE INTO refs(file, word) VALUES ((SELECT id FROM files WHERE file = '$F'), (SELECT id FROM words WHERE word = '$w'));" >> $T
    done
fi
echo 'COMMIT;' >> $T;
sqlite3 "$DB" <<EOT
.bail off
.separator ,
.read $T
EOT
#sync -f "$DB"
