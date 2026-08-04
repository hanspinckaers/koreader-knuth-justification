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
    frontend/apps/reader/modules/readertypeset.lua \
    frontend/ui/data/creoptions.lua
do
    if ! cmp -s "$repo_dir/combined/$path" "$koreader_dir/$path"; then
        echo "different: $path" >&2
        status=1
    fi
done

if [ -d "$koreader_dir/plugins/knuthjustification.koplugin" ]; then
    echo "unexpected: Knuth plugin still present" >&2
    status=1
fi
if ! cmp -s "$repo_dir/combined/plugins/profiles.koplugin/main.lua" \
        "$koreader_dir/plugins/profiles.koplugin/main.lua"; then
    echo "different: integrated Profiles" >&2
    status=1
fi
for patch in 10-knuth-cre 11-knuth-profiles 12-kerning-profiles; do
    if ! cmp -s "$repo_dir/combined/patches/${patch}-integrated.lua" \
            "$koreader_dir/patches/$patch.lua"; then
        echo "different: patches/$patch.lua" >&2
        status=1
    fi
done

exit "$status"
