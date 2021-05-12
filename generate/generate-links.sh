#!/bin/sh

set -eu

# Constants
TXT_DIRECTORY=txt

# Get books
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )

for t in $TRANSLATIONS; do
    BIBLE_BOOK_CHAPTER_DIR="$TXT_DIRECTORY/$t/chapters"
    find "$BIBLE_BOOK_CHAPTER_DIR" -type f
done