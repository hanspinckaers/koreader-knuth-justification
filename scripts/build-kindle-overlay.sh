#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
koreader_dir=${1:?usage: build-kindle-overlay.sh /path/to/koreader-v2026.07.1 [output.zip]}
output=${2:-$repo_dir/dist/koreader-knuth-page-v2026.07.1-kindle-overlay.zip}
toolchain_bin=${KINDLE_TOOLCHAIN_BIN:-/root/x-tools/arm-kindle5-linux-gnueabi/bin}

"$repo_dir/scripts/sync-to-koreader.sh" "$koreader_dir"
"$repo_dir/scripts/check-source-sync.sh" "$koreader_dir"
"$repo_dir/scripts/test-native-helpers.sh"

PATH="$toolchain_bin:$PATH" ninja \
    -C "$koreader_dir/build-kindle4/thirdparty/crengine/build" -j2
PATH="$toolchain_bin:$PATH" ninja \
    -C "$koreader_dir/build-kindle4/koreader" -j2 koreader-cre

"$repo_dir/scripts/package-overlay.sh" \
    "$koreader_dir/build-kindle4/libs/libkoreader-cre.so" "$output"
