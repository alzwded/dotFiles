#!/bin/bash

ME="$(dirname "$(realpath "$0")")"
BUILDER="$ME/worddb_build1.sh"
DB="${WORDDBPATH:-worddb.sqlite3}"

rm -rf "$DB"
sqlite3 "$DB" <<EOT
CREATE TABLE data(word, file, CONSTRAINT uuu UNIQUE(word, file) ON CONFLICT IGNORE);
CREATE INDEX qqq ON data(word);
EOT

for PPP in "$@" ; do
    if [[ -d "$PPP" ]] ; then
        find "$PPP" -type f -exec perl -e 'exit((-T $ARGV[0])?0:1);' '{}' ';' -print -exec "$BUILDER" '{}' ';'
    else
        perl -e 'exit((-T $ARGV[0])?0:1);' "$PPP" && echo "$PPP" && "$BUILDER" "$PPP"
    fi
done
