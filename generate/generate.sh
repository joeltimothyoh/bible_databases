#!/bin/sh

# This script generates the index.md

set -eu

# Constants
TXT_DIRECTORY=txt
LINKS_DIRECTORY=links
LINKS_FILE="$LINKS_DIRECTORY/links.txt"

# Globals
CONTENT=

# Get books
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )
BOOKS_PATHS_ALL=$(
    for TRANSLATION in $TRANSLATIONS; do
        ls "$TXT_DIRECTORY/$TRANSLATION" | sort -n | while read -r BOOK_FILE_NAME; do
            echo "$TXT_DIRECTORY/$TRANSLATION/$BOOK_FILE_NAME"
        done
    done )
BOOKS=$( ls "$TXT_DIRECTORY/YLT" | sort -n | sed 's@^[0-9]\+\s\+\([^-]\+\)\s\+.*@\1@' )

# Generate index.md
FILE=index.md
MD_TABLE_TITLE="| BOOK $( for TRANSLATION in $TRANSLATIONS; do echo "| $TRANSLATION"; done | tr -d '\n' ) |"
MD_TABLE_ALIGNER="|---$( printf "%$( echo "$TRANSLATIONS" | wc -l )s" | sed 's/ /\|---/g' )|"
MD_TABLE_CONTENT=$(
    echo "$BOOKS" | while read -r BOOK; do
        _LINE="| $BOOK "
        for TRANSLATION in $TRANSLATIONS; do
            _LINE=$( echo "$_LINE | [read]($( echo "$BOOKS_PATHS_ALL" | grep -E "$TXT_DIRECTORY/$TRANSLATION/[0-9]+\s+$BOOK.*\($TRANSLATION\).txt" | sed 's/ /%20/g' ))" )
        done
        echo "$_LINE"
    done
)
cat - > "$FILE" <<EOF
# Read the bible

Select a book to read:

$MD_TABLE_TITLE
$MD_TABLE_ALIGNER
$MD_TABLE_CONTENT

Full list of links can be found [here]($LINKS_FILE).

EOF
echo "$FILE"

# Generate links.txt
TXT_LINKS=$( echo "$BOOKS_PATHS_ALL" | sed 's@\(.*\)@https://leojonathanoh.github.io/bible_databases/\1@' | sed 's/ /%20/g' )
echo "$TXT_LINKS" > "$LINKS_FILE"
echo "$LINKS_FILE"
