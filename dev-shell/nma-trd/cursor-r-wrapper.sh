#!/bin/bash
# This script helps Cursor find the R executable
if [ -n "$CURSOR_R_PATH" ]; then
  exec "$CURSOR_R_PATH" "$@"
else
  exec "/nix/store/9akw41vydf6307xsxi4xjn53prn9xnf6-R-4.4.3-wrapper/bin/R" "$@"
fi
