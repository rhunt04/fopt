#!/usr/bin/env sh

# RJH
# Shell script for calling valgrind with my favourite options on
# ./build*/bin/main.

# Requires valgrind...!
command -v valgrind >/dev/null 2>&1 ||
  { echo "Can't find valgrind. Aborting." >&2; exit 1; }

valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind-out.txt \
         ./build*/bin/main
