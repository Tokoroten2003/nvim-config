#!/usr/bin/env bash

# functions
function check_dest() {
    if   [ -L "$1" ]; then
        echo "link-exists ${1}"
    elif [ -f "$1" ]; then
        echo "file-exists ${1}"
    else
        echo "not-exists ${1}"
    fi
}

function resolve_dest() {
    STATUS=$1
    FILE=$2
    if [[ "$STATUS" = "link-exists" ]]; then
        echo "Unlink $FILE"
        unlink "$FILE"
    elif [[ "$STATUS" = "file-exists" ]]; then
        echo "Move $FILE to $FILE.old (if $FILE.old already exists, remove old one)"
        [[ -e "$FILE.old" ]] && rm "$FILE.old"
        mv "$FILE" "$FILE.old"
    fi
}

# link files
ROOT="$(cd $(dirname ${BASH_SOURCE:-$0}) && pwd)/files"

FILES=$(find "$ROOT/" -type f)

echo "Resolving existing files..."
echo $FILES | while read file; do
    [[ ! -n "$file" ]] && continue
    DEST="$HOME/.config/nvim/${file#"$ROOT/"}"
    DEST_D=$(dirname "$DEST")
    mkdir -p "$DEST_D"
    resolve_dest $(check_dest "$DEST")
done
echo ""

echo "Creating new links..."
echo $FILES | while read file; do
    [[ ! -n "$file" ]] && continue
    SRC="$file"
    DEST="$HOME/.config/nvim/${file#"$ROOT"}"
    echo "$SRC"
    echo " -> $DEST"
    ln -s "$SRC" "$DEST"
done
echo ""

