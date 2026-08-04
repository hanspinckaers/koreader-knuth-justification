#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 /path/to/koreader-v2026.07.1" >&2
    exit 2
fi

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
koreader_dir=$(CDPATH= cd -- "$1" && pwd)
crengine_dir="$koreader_dir/base/thirdparty/kpvcrlib/crengine"

"$repo_dir/scripts/sync-to-koreader.sh" "$koreader_dir"

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
    install -m 0644 "$repo_dir/combined/native/overlay/$path" "$crengine_dir/$path"
done

for path in \
    frontend/document/credocument.lua \
    frontend/apps/reader/modules/readerfont.lua \
    frontend/ui/data/creoptions.lua
do
    install -m 0644 "$repo_dir/combined/$path" "$koreader_dir/$path"
done

rm -rf "$koreader_dir/plugins/knuthjustification.koplugin"
mkdir -p "$koreader_dir/plugins/knuthjustification.koplugin"
cp -R "$repo_dir/combined/plugin/." \
    "$koreader_dir/plugins/knuthjustification.koplugin/"
install -m 0644 "$repo_dir/combined/patches/12-kerning-profiles.lua" \
    "$koreader_dir/patches/12-kerning-profiles.lua"

echo "Synced combined Knuth + fractional-kerning sources into $koreader_dir"
