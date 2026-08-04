#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
koreader_dir=${1:?usage: build-combined-kindle.sh /path/to/koreader-v2026.07.1 official-kindle.zip [output.zip]}
official_zip=${2:?usage: build-combined-kindle.sh /path/to/koreader-v2026.07.1 official-kindle.zip [output.zip]}
output=${3:-$repo_dir/dist/koreader-v2026.07.1-kindle-knuth-fractional-literata.zip}
toolchain_bin=${KINDLE_TOOLCHAIN_BIN:-/root/x-tools/arm-kindle5-linux-gnueabi/bin}

"$repo_dir/scripts/sync-combined-to-koreader.sh" "$koreader_dir"
"$repo_dir/scripts/check-combined-source-sync.sh" "$koreader_dir"
"$repo_dir/scripts/test-native-helpers.sh"

PATH="$toolchain_bin:$PATH" ninja \
    -C "$koreader_dir/build-kindle4/thirdparty/crengine/build" -j2
PATH="$toolchain_bin:$PATH" ninja \
    -C "$koreader_dir/build-kindle4/koreader" -j2 koreader-cre

"$repo_dir/scripts/package-combined-kindle.sh" "$official_zip" \
    "$koreader_dir/build-kindle4/libs/libkoreader-cre.so" "$output"
