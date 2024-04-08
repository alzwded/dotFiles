#!/bin/bash

DB="${WORDDBPATH:-worddb.sqlite3}"
STRICTLYWORDS=0
F="$( realpath "$1" )"
T=$(mktemp)
_Fid=$( sqlite3 "$DB" "INSERT OR IGNORE INTO files(file) VALUES('$F'); SELECT id FROM files WHERE file = '$F';" )
echo 'BEGIN TRANSACTION;' > $T
trap 'rm -f $T' EXIT

# can't decide how wise it is to include -
# maybe s/^-*(.*)-*$/\1/ at the end? For later
#for w in $( tr -sC '[a-zA-Z0-9_\-]' '\n' < "$F" ) ; do
for w in $( tr -sC '[a-zA-Z0-9_]' '\n' < "$F" ) ; do
    # it's somehow faster when these two are on the same line o_O
    echo "INSERT OR IGNORE INTO words(word) VALUES ('$w');" \
    "INSERT OR IGNORE INTO refs(word, file) VALUES ((SELECT id FROM words WHERE word = '$w'), $_Fid);" >> $T
done
echo 'COMMIT;' >> $T;
sqlite3 "$DB" <<EOT
.bail off
.separator ,
.read $T
EOT
#sync -f "$DB"
