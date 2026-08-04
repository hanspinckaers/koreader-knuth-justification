#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 /path/to/patched-koreader-v2026.07.1" >&2
    exit 2
fi

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
koreader_dir=$(CDPATH= cd -- "$1" && pwd)
crengine_dir="$koreader_dir/base/thirdparty/kpvcrlib/crengine"

status=0
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
    if ! cmp -s "$repo_dir/native/overlay/$path" "$crengine_dir/$path"; then
        echo "different: $path" >&2
        status=1
    fi
done

if ! diff -qr "$repo_dir/plugin" "$koreader_dir/plugins/knuthjustification.koplugin" >/dev/null; then
    echo "different: plugin" >&2
    status=1
fi
for path in 10-knuth-cre.lua 11-knuth-profiles.lua; do
    if ! cmp -s "$repo_dir/patches/$path" "$koreader_dir/patches/$path"; then
        echo "different: patches/$path" >&2
        status=1
    fi
done

exit "$status"
