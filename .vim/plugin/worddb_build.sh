#!/bin/bash

ME="$(dirname "$(realpath "$0")")"
BUILDER="$ME/worddb_build1.sh"
DB="${WORDDBPATH:-worddb.sqlite3}"

rm -rf "$DB" "$DB"
sqlite3 "$DB" <<EOT
-- permanent tables
CREATE TABLE words(id INTEGER PRIMARY KEY AUTOINCREMENT, word, CONSTRAINT unique_words UNIQUE(word) ON CONFLICT IGNORE);
CREATE TABLE files(id INTEGER PRIMARY KEY AUTOINCREMENT, file, CONSTRAINT unique_files UNIQUE(file) ON CONFLICT IGNORE);
CREATE TABLE refs(file INTEGER, word INTEGER, FOREIGN KEY(file) REFERENCES files(id), FOREIGN KEY(word) REFERENCES words(id), CONSTRAINT unique_refs UNIQUE(word, file) ON CONFLICT IGNORE);
EOT

# build temp DB, flat
for PPP in "$@" ; do
    if [[ "$PPP" =~ ^@ ]] ; then
        IFS='
'
        for PPPP in $( cat "${PPP#@}" ) ; do
            if [[ -d "$PPPP" ]] ; then
                find "$PPPP" -type f -exec perl -e 'exit((-T $ARGV[0])?0:1);' '{}' ';' -print -exec "$BUILDER" '{}' ';'
            else
                perl -e 'exit((-T $ARGV[0])?0:1);' "$PPPP" && echo "$PPPP" && "$BUILDER" "$PPPP"
            fi
        done
    fi
    if [[ -d "$PPP" ]] ; then
        find "$PPP" -type f -exec perl -e 'exit((-T $ARGV[0])?0:1);' '{}' ';' -print -exec "$BUILDER" '{}' ';'
    else
        perl -e 'exit((-T $ARGV[0])?0:1);' "$PPP" && echo "$PPP" && "$BUILDER" "$PPP"
    fi
done

sqlite3 "$DB" <<EOT
-- index for fastest word lookups
CREATE INDEX aaa ON refs(word);
EOT
