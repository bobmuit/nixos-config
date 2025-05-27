{ config, pkgs, ... }:

{
  # Joplin settings
  programs.joplin-desktop = {
    enable = true;
    sync = {
      target = "joplin-server";
      interval = "5m";
    };
    extraConfig = {
      "sync.target" = 9;
      "sync.9.path" = "http://192.168.1.180:22300";
      "sync.9.username" = "bob@bobmuit.nl";
      "locale" = "en_GB";
      "theme" = 2;
      "themeAutoDetect" = true;
    };
  };
}