#!/bin/sh

set -eu

# Constants
TXT_DIRECTORY=txt

# Get books
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )

for t in $TRANSLATIONS; do
    ls -p "$TXT_DIRECTORY/$t" | grep -v / | while read -r BOOK; do
        # mkdir -p "$CHAPTER_DIR"
        # E.g. 1 Genesis
        BIBLE_BOOK_TITLE_WITH_INDEX=$( echo "$BOOK" | head -n1 | sed 's@^\([0-9]\+\s\+[^-]\+\)\s\+.*@\1@')
        # E.g. 1, 10, 100
        BIBLE_BOOK_CHAPTERS=$( cat "$TXT_DIRECTORY/$t/$BOOK" | cut -d ':' -f1 | tr -d '[' | uniq | grep -E '^[0-9]+$' )
        # E.g. txt/YLT/chapters
        BIBLE_BOOK_CHAPTER_DIR="$TXT_DIRECTORY/$t/chapters"
        mkdir -p "$TXT_DIRECTORY/$t/chapters"
        # Debug
        for c in $BIBLE_BOOK_CHAPTERS; do
            # e.g. txt/YLT/chapters/1 Genesis 1.txt
            # e.g. txt/YLT/chapters/66 Revelation 22.txt
            echo "Creating chapter file: $BIBLE_BOOK_CHAPTER_DIR/$BIBLE_BOOK_TITLE_WITH_INDEX $c.txt"
            cat "$TXT_DIRECTORY/$t/$BOOK" | grep -E "^\[$c:" > "$BIBLE_BOOK_CHAPTER_DIR/$BIBLE_BOOK_TITLE_WITH_INDEX $c.txt"
        done
    done
done