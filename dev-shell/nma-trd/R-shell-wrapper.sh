#!/bin/bash
# This script helps VSCode use the R from the nix shell
nix develop -c R "$@"
