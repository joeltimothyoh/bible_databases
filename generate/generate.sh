#!/bin/sh

# This script generates the index.md

set -eu

# Constants
TXT_DIRECTORY=txt

# Globals
CONTENT=

# Get books
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )
BOOKS_PATHS_ALL=$( find "$TXT_DIRECTORY" -type f )
BOOKS=$( ls "$TXT_DIRECTORY/YLT" | sort -n | sed 's@^[0-9]\+\s\+\([^-]\+\)\s\+.*@\1@' )

# Generate the markdown sections
MD_FILE=index.md
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

# Write the markdown content
cat - > "$MD_FILE" <<EOF
# Read the bible

$MD_TABLE_TITLE
$MD_TABLE_ALIGNER
$MD_TABLE_CONTENT
EOF
echo "$MD_FILE"