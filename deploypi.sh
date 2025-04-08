#!/usr/bin/env bash

set -e

PI_USER=nixos
PI_HOST=192.168.1.63
PI_TARGET_DIR=/home/nixos/nixos-config-remote
FLAKE_REF=nixos-pi

# 1. Sync the nixos-config directory to the Pi
echo "🔄 Syncing config to $PI_HOST..."
rsync -avz --delete --exclude=".git" ./ "$PI_USER@$PI_HOST:$PI_TARGET_DIR"

# 2. Trigger the build remotely
echo "⚙️  Running nixos-rebuild switch on the Pi..."
ssh "$PI_USER@$PI_HOST" "sudo nixos-rebuild switch --flake $PI_TARGET_DIR#$FLAKE_REF"
