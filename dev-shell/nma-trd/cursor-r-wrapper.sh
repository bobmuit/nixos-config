#!/bin/bash
# This script helps Cursor find the R executable
if [ -n "$CURSOR_R_PATH" ]; then
  exec "$CURSOR_R_PATH" "$@"
else
  exec "/nix/store/ad9xyj8qx3mbd4vxcgci2wjlcx4dw3zy-R-4.4.3-wrapper/bin/R" "$@"
fi
