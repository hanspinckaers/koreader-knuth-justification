#!/bin/sh
set -eu

archive=${1:?usage: validate-overlay.sh overlay.zip [official-libkoreader-cre.so]}
stock_library=${2:-}
custom_path=koreader/libs/libkoreader-cre-knuth-page-v2026.07.1.so

unzip -tqq "$archive"
for required in \
    "$custom_path" \
    koreader/patches/10-knuth-cre.lua \
    koreader/patches/11-knuth-profiles.lua \
    koreader/plugins/knuthjustification.koplugin/_meta.lua \
    koreader/plugins/knuthjustification.koplugin/main.lua
do
    if ! unzip -Z1 "$archive" | grep -Fxq "$required"; then
        echo "Missing archive entry: $required" >&2
        exit 1
    fi
done
if unzip -Z1 "$archive" | grep -Fxq koreader/libs/libkoreader-cre.so; then
    echo "Overlay must not replace official libkoreader-cre.so" >&2
    exit 1
fi

temp_dir=$(mktemp -d /tmp/koreader-knuth-validation.XXXXXX)
trap 'rm -rf -- "$temp_dir"' EXIT HUP INT TERM
unzip -q "$archive" "$custom_path" -d "$temp_dir"
custom_library=$temp_dir/$custom_path
file "$custom_library" | grep -q 'ELF 32-bit LSB shared object, ARM'

if readelf --version-info "$custom_library" | \
        grep -E 'Name: GLIBC_([3-9]|2\.([89]|[1-9][0-9]))' >/dev/null; then
    echo "Native overlay requires a GLIBC newer than Kindle supports" >&2
    exit 1
fi

if [ -n "$stock_library" ]; then
    readelf -Ws "$stock_library" | \
        awk '$7 == "UND" { sub(/@.*/, "", $8); print $8 }' | sort -u \
        > "$temp_dir/stock.und"
    readelf -Ws "$custom_library" | \
        awk '$7 == "UND" { sub(/@.*/, "", $8); print $8 }' | sort -u \
        > "$temp_dir/custom.und"
    if ! cmp -s "$temp_dir/stock.und" "$temp_dir/custom.und"; then
        echo "Undefined-symbol set differs from the official native module" >&2
        diff -u "$temp_dir/stock.und" "$temp_dir/custom.und" >&2 || true
        exit 1
    fi
fi

sha256sum "$archive"
