#!/bin/bash
find  $PWD -iname '*.h' -o -iname '*.cpp' -o -iname '*.cc' | xargs clang-format-10 -i -style=file
