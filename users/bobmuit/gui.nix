{ config, pkgs, inputs, lib, ... }:

{
  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Imported modules
  imports = [
    ../../modules/home-manager/programs/firefox.nix
    ../../modules/home-manager/programs/vscode.nix
    ../../modules/home-manager/programs/joplin.nix
    ../../modules/home-manager/services/gnome.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
  ];

  # Autostart SynologyDrive on startup
  home.file.".config/autostart/synology-drive.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Synology Drive
    Exec=/run/current-system/sw/bin/synology-drive
    X-GNOME-Autostart-enabled=true
  '';
}