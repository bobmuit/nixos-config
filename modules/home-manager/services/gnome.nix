{ config, pkgs, ... }:

{
  # Gnome settings
  dconf.settings = {
    # Enable minimize and maximize buttons in GNOME
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell" = {
      # Enable extensions
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "status-icons@gnome-shell-extensions.gcampax.github.com"
      ];

      # Arrange favourite apps
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "proton-mail.desktop"
        "kuro.desktop"
        "joplin-desktop.desktop"
        "firefox.desktop"
        "bitwarden.desktop"
        "codium.desktop"
        "spotify.desktop"
        "vmware-view.desktop"
        "teams-for-linux.desktop"
        "zotero.desktop"
      ];
    };

    # Dash-to-dock settings
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = true;
      extend-height = true;
      intellihide-mode = "NONE";
      height-fraction = 1.0;
      dash-max-icon-size = 32;
      panel-mode = true;
    };

    # Disable unnecessary GNOME services
    "org/gnome/settings-daemon/plugins/print-notifications" = {
      active = "false";
    };
    "org/gnome/settings-daemon/plugins/smartcard" = {
      active = "false";
    };
    "org/gnome/settings-daemon/plugins/wacom" = {
      active = "false";
    };
  };
}
