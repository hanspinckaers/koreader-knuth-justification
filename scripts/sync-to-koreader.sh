#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 /path/to/koreader-v2026.07.1" >&2
    exit 2
fi

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
koreader_dir=$(CDPATH= cd -- "$1" && pwd)
base_dir="$koreader_dir/base"
crengine_dir="$base_dir/thirdparty/kpvcrlib/crengine"

expected_koreader=9192014d8bd82a91dc1012473be0f238dedfdb54
expected_base=6e4bc81a
expected_crengine=b32a88ff

actual_koreader=$(git -C "$koreader_dir" rev-parse HEAD)
actual_base=$(git -C "$base_dir" rev-parse --short=8 HEAD)
actual_crengine=$(git -C "$crengine_dir" rev-parse --short=8 HEAD)

if [ "$actual_koreader" != "$expected_koreader" ]; then
    echo "unsupported KOReader commit: $actual_koreader" >&2
    exit 1
fi
if [ "$actual_base" != "$expected_base" ]; then
    echo "unsupported koreader-base commit: $actual_base" >&2
    exit 1
fi
if [ "$actual_crengine" != "$expected_crengine" ]; then
    echo "unsupported CREngine commit: $actual_crengine" >&2
    exit 1
fi

for path in \
    crengine/include/lvdocview.h \
    crengine/include/lvdocviewprops.h \
    crengine/include/lvfntman.h \
    crengine/include/lvtextfm.h \
    crengine/include/lvtinydom.h \
    crengine/src/lvdocview.cpp \
    crengine/src/lvfntman.cpp \
    crengine/src/lvtextfm.cpp \
    crengine/src/lvtinydom.cpp
do
    install -m 0644 "$repo_dir/native/overlay/$path" "$crengine_dir/$path"
done

rm -rf "$koreader_dir/plugins/knuthjustification.koplugin"
mkdir -p "$koreader_dir/plugins/knuthjustification.koplugin"
cp -R "$repo_dir/plugin/." "$koreader_dir/plugins/knuthjustification.koplugin/"
install -m 0644 "$repo_dir/patches/10-knuth-cre.lua" "$koreader_dir/patches/10-knuth-cre.lua"
install -m 0644 "$repo_dir/patches/11-knuth-profiles.lua" "$koreader_dir/patches/11-knuth-profiles.lua"

echo "Synced Knuth sources into $koreader_dir"
