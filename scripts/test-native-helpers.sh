#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build_dir="$repo_dir/build/tests"
mkdir -p "$build_dir"

${CXX:-c++} -std=c++11 -Wall -Wextra -Werror \
    -I"$repo_dir/native/overlay/crengine/include" \
    "$repo_dir/tests/page_word_spacing_test.cpp" \
    -o "$build_dir/page_word_spacing_test"
"$build_dir/page_word_spacing_test"

${CXX:-c++} -std=c++11 -Wall -Wextra -Werror \
    -I"$repo_dir/combined/native/overlay/crengine/include" \
    "$repo_dir/tests/fractional_tracking_test.cpp" \
    -o "$build_dir/fractional_tracking_test"
"$build_dir/fractional_tracking_test"
