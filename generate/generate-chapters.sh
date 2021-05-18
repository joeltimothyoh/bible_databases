#!/bin/sh

set -eu

# Constants
TXT_DIRECTORY=txt

# Get books
TRANSLATIONS=$( ls "$TXT_DIRECTORY" )

CHAPTERS_PATHS_ALL=$(
    for TRANSLATION in $TRANSLATIONS; do
        ls -p "$TXT_DIRECTORY/$TRANSLATION/books" | grep -v / | sort -n | while read -r BOOK; do
            echo "Generating chapters for $TXT_DIRECTORY/$TRANSLATION/books/$BOOK" >&2
            # E.g. 1 Genesis
            BIBLE_BOOK_TITLE_WITH_INDEX=$( echo "$BOOK" | head -n1 | sed 's@^\([0-9]\+\s\+[^-]\+\)\s\+.*@\1@')
            # Strip off the index. E.g. 1 Genesis -> Genesis
            BIBLE_BOOK_TITLE=$( echo "$BIBLE_BOOK_TITLE_WITH_INDEX" | sed 's@^[0-9]\+\s\+@@' )
            # E.g. 1, 10, 100
            BIBLE_BOOK_CHAPTERS=$( cat "$TXT_DIRECTORY/$TRANSLATION/books/$BOOK" | cut -d ':' -f1 | tr -d '[' | uniq | grep -E '^[0-9]+$' )
            # E.g. txt/YLT/chapters
            BIBLE_BOOK_CHAPTER_DIR="$TXT_DIRECTORY/$TRANSLATION/chapters"
            mkdir -p "$TXT_DIRECTORY/$TRANSLATION/chapters"
            for c in $BIBLE_BOOK_CHAPTERS; do
                # E.g. txt/YLT/chapters/1 Genesis 1.txt
                # E.g. txt/YLT/chapters/66 Revelation 22.txt
                echo "Creating chapter file: $BIBLE_BOOK_CHAPTER_DIR/$BIBLE_BOOK_TITLE $c.txt" >&2
                # cat "$TXT_DIRECTORY/$TRANSLATION/books/$BOOK" | grep -E "^\[$c:" > "$BIBLE_BOOK_CHAPTER_DIR/$BIBLE_BOOK_TITLE $c.txt"
                echo "$BIBLE_BOOK_CHAPTER_DIR/$BIBLE_BOOK_TITLE $c.txt"
            done
        done
    done )

# Truncate the final newline in chapter content
echo "$CHAPTERS_PATHS_ALL" | while read -r CHAPTER_PATH; do
    length=$(wc -c <"$CHAPTER_PATH")
    if [ "$length" -ne 0 ] && [ -z "$(tail -c -1 <"$CHAPTER_PATH")" ]; then
    # The file ends with a newline or null
    dd if=/dev/null of="$CHAPTER_PATH" obs="$((length-1))" seek=1
    fi
done

echo 'done'
