#!/bin/sh

# This script generates the index.md

set -eu

# Constants
TXT_DIRECTORY=txt
LINKS_DIRECTORY=links
LINKS_BOOKS_FILE="$LINKS_DIRECTORY/links-books.txt"
LINKS_CHAPTERS_FILE="$LINKS_DIRECTORY/links-chapters.txt"

# Globals
CONTENT=

# Get translations
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )

# Get books
BOOKS_PATHS_ALL=$(
    for TRANSLATION in $TRANSLATIONS; do
        ls -p "$TXT_DIRECTORY/$TRANSLATION/books" | grep -v / | sort -n | while read -r NAME; do
            echo "$TXT_DIRECTORY/$TRANSLATION/books/$NAME"
        done
    done )
BOOKS=$( ls "$TXT_DIRECTORY/YLT" | sort -n | sed 's@^[0-9]\+\s\+\([^-]\+\)\s\+.*@\1@' )

# Get chapters
CHAPTERS_PATHS_ALL=$(
    for TRANSLATION in $TRANSLATIONS; do
        ls "$TXT_DIRECTORY/$TRANSLATION/chapters" | sort -n -k1 -k3 -k4 | while read -r NAME; do
            echo "$TXT_DIRECTORY/$TRANSLATION/chapters/$NAME"
        done
    done )

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

Full list of book links can be found [here]($LINKS_BOOKS_FILE).

Full list of chapter links can be found [here]($LINKS_CHAPTERS_FILE).

EOF
echo "$FILE"

# Generate links-books.txt
TXT_LINKS=$( echo "$BOOKS_PATHS_ALL" | sed 's@\(.*\)@https://leojonathanoh.github.io/bible_databases/\1@' | sed 's/ /%20/g' )
echo "$TXT_LINKS" > "$LINKS_BOOKS_FILE"
echo "$LINKS_BOOKS_FILE"

# # Generate links-chapters.txt
TXT_LINKS=$( echo "$CHAPTERS_PATHS_ALL" | sed 's@\(.*\)@https://leojonathanoh.github.io/bible_databases/\1@' | sed 's/ /%20/g' )
echo "$TXT_LINKS" > "$LINKS_CHAPTERS_FILE"
echo "$LINKS_CHAPTERS_FILE"
