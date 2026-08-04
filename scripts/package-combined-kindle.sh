#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
official_zip=${1:?usage: package-combined-kindle.sh official-kindle.zip built-libkoreader-cre.so [output.zip]}
built_library=${2:?usage: package-combined-kindle.sh official-kindle.zip built-libkoreader-cre.so [output.zip]}
output=${3:-$repo_dir/dist/koreader-v2026.07.1-kindle-knuth-fractional-literata.zip}
case "$output" in
    /*) ;;
    *) output=$(pwd)/$output ;;
esac

unzip -tqq "$official_zip"
if [ ! -f "$built_library" ]; then
    echo "Native library not found: $built_library" >&2
    exit 1
fi

mkdir -p "$repo_dir/dist"
stage_dir=$(mktemp -d "$repo_dir/dist/combined-package.XXXXXX")
archive_dir=$(mktemp -d "$repo_dir/dist/combined-archive.XXXXXX")
trap 'rm -rf -- "$stage_dir" "$archive_dir"' EXIT HUP INT TERM
unzip -q "$official_zip" -d "$stage_dir"

install -D -m 0644 "$built_library" \
    "$stage_dir/koreader/libs/libkoreader-cre-knuth-page-v2026.07.1.so"
install -D -m 0644 "$repo_dir/patches/10-knuth-cre.lua" \
    "$stage_dir/koreader/patches/10-knuth-cre.lua"
install -D -m 0644 "$repo_dir/patches/11-knuth-profiles.lua" \
    "$stage_dir/koreader/patches/11-knuth-profiles.lua"
install -D -m 0644 "$repo_dir/combined/patches/12-kerning-profiles.lua" \
    "$stage_dir/koreader/patches/12-kerning-profiles.lua"

rm -rf "$stage_dir/koreader/plugins/knuthjustification.koplugin"
mkdir -p "$stage_dir/koreader/plugins/knuthjustification.koplugin"
cp -R "$repo_dir/combined/plugin/." \
    "$stage_dir/koreader/plugins/knuthjustification.koplugin/"

for path in \
    frontend/document/credocument.lua \
    frontend/apps/reader/modules/readerfont.lua \
    frontend/ui/data/creoptions.lua
do
    install -m 0644 "$repo_dir/combined/$path" "$stage_dir/koreader/$path"
done

install -D -m 0644 "$repo_dir/combined/fonts/Literata-Variable.ttf" \
    "$stage_dir/koreader/fonts/Literata-Variable.ttf"
install -D -m 0644 "$repo_dir/combined/fonts/Literata-Italic-Variable.ttf" \
    "$stage_dir/koreader/fonts/Literata-Italic-Variable.ttf"
install -D -m 0644 "$repo_dir/combined/fonts/OFL-Literata.txt" \
    "$stage_dir/koreader/fonts/OFL-Literata.txt"
install -m 0644 "$repo_dir/packaging/README-COMBINED-v2026.07.1.txt" \
    "$stage_dir/README-COMBINED-v2026.07.1.txt"

find "$stage_dir" -exec touch -h -t 202607010000.00 {} +
mkdir -p "$(dirname -- "$output")"
(cd "$stage_dir" && 7z a -bd -bso0 -bsp0 -tzip -mx=9 \
    -mtc=off -mtm=off -mta=off "$archive_dir/combined.zip" .)
mv -f "$archive_dir/combined.zip" "$output"
unzip -tqq "$output"
sha256sum "$output"
