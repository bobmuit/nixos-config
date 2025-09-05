{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./core.nix
    ./gui.nix
  ];
}

