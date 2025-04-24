#!/bin/bash
# This script helps Cursor find the R executable
if [ -n "$CURSOR_R_PATH" ]; then
  exec "$CURSOR_R_PATH" "$@"
else
  exec "/nix/store/wwixvds3h13vnpg37sy7a7bxdh9c21li-R-4.4.3-wrapper/bin/R" "$@"
fi
