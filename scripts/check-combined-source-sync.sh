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
    crengine/include/knuthpagespacing.h \
    crengine/include/lvfntman.h \
    crengine/include/lvpagesplitter.h \
    crengine/include/lvtextfm.h \
    crengine/include/lvtinydom.h \
    crengine/src/lvdocview.cpp \
    crengine/src/lvfntman.cpp \
    crengine/src/lvpagesplitter.cpp \
    crengine/src/lvrend.cpp \
    crengine/src/lvtextfm.cpp \
    crengine/src/lvtinydom.cpp
do
    if ! cmp -s "$repo_dir/combined/native/overlay/$path" "$crengine_dir/$path"; then
        echo "different: $path" >&2
        status=1
    fi
done

for path in \
    frontend/document/credocument.lua \
    frontend/apps/reader/modules/readerfont.lua \
    frontend/ui/data/creoptions.lua
do
    if ! cmp -s "$repo_dir/combined/$path" "$koreader_dir/$path"; then
        echo "different: $path" >&2
        status=1
    fi
done

if ! diff -qr "$repo_dir/combined/plugin" \
        "$koreader_dir/plugins/knuthjustification.koplugin" >/dev/null; then
    echo "different: combined plugin" >&2
    status=1
fi
if ! cmp -s "$repo_dir/combined/patches/12-kerning-profiles.lua" \
        "$koreader_dir/patches/12-kerning-profiles.lua"; then
    echo "different: patches/12-kerning-profiles.lua" >&2
    status=1
fi

exit "$status"
