#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
built_library=${1:?usage: package-overlay.sh /path/to/libkoreader-cre.so [output.zip]}
output=${2:-$repo_dir/dist/koreader-knuth-page-v2026.07.1-kindle-overlay.zip}
case "$output" in
    /*) ;;
    *) output=$(pwd)/$output ;;
esac

if [ ! -f "$built_library" ]; then
    echo "Native library not found: $built_library" >&2
    exit 1
fi

mkdir -p "$repo_dir/dist"
stage_dir=$(mktemp -d "$repo_dir/dist/package.XXXXXX")
archive_dir=$(mktemp -d "$repo_dir/dist/archive.XXXXXX")
trap 'rm -rf -- "$stage_dir" "$archive_dir"' EXIT HUP INT TERM

install -D -m 0644 "$built_library" \
    "$stage_dir/koreader/libs/libkoreader-cre-knuth-page-v2026.07.1.so"
install -D -m 0644 "$repo_dir/patches/10-knuth-cre.lua" \
    "$stage_dir/koreader/patches/10-knuth-cre.lua"
install -D -m 0644 "$repo_dir/patches/11-knuth-profiles.lua" \
    "$stage_dir/koreader/patches/11-knuth-profiles.lua"
install -D -m 0644 "$repo_dir/plugin/_meta.lua" \
    "$stage_dir/koreader/plugins/knuthjustification.koplugin/_meta.lua"
install -D -m 0644 "$repo_dir/plugin/main.lua" \
    "$stage_dir/koreader/plugins/knuthjustification.koplugin/main.lua"
install -m 0644 "$repo_dir/packaging/README-KNUTH-PAGE-v2026.07.1.txt" \
    "$stage_dir/README-KNUTH-PAGE-v2026.07.1.txt"

# Stable timestamps and stripped ZIP metadata make repeated packaging
# byte-for-byte reproducible when the inputs are unchanged.
find "$stage_dir" -exec touch -h -t 202607010000.00 {} +
mkdir -p "$(dirname -- "$output")"
(cd "$stage_dir" && 7z a -bd -bso0 -bsp0 -tzip -mx=9 \
    -mtc=off -mtm=off -mta=off "$archive_dir/overlay.zip" .)
mv -f "$archive_dir/overlay.zip" "$output"
unzip -tqq "$output"
sha256sum "$output"
