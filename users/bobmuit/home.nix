{ config, pkgs, inputs, lib, ... }:

{
    
  home.username = "bobmuit";
  home.homeDirectory = "/home/bobmuit";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Imported modules
  imports = [
    ../../modules/home-manager/programs/browsers.nix
    ../../modules/home-manager/programs/shells.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Prevent dev-shells from being garbage collected
    # Run 'nix-dev' to enable dev-shell flake and create profile
    (pkgs.writeShellScriptBin "nix-dev" ''
        set -euo pipefail

        PROFILE_DIR="$HOME/.nix-devenvs"
        mkdir -p "$PROFILE_DIR"

        # Try to get Git project name
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
          GIT_ROOT=$(git rev-parse --show-toplevel)
          PROJECT_NAME=$(basename "$GIT_ROOT")
        else
          PROJECT_NAME="no-git"
        fi

        # Add short hash to the project name (for uniqueness)
        PROJECT_HASH=$(echo "$PWD" | sha256sum | cut -c1-8)

        # Combine git project name and hash
        PROFILE_PATH="$PROFILE_DIR/$PROJECT_NAME-$PROJECT_HASH"

        echo "Launching nix develop with profile: $PROFILE_PATH"
        exec nix develop --profile "$PROFILE_PATH" "$@"
    '')

  ];

  # VSCodium settings
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide # Nix language support extension
      reditorsupport.r # R Language
      redhat.vscode-yaml # YAML support extension
      yzhang.markdown-all-in-one # Markdown All in One
      # insert-unicode not available in nixpkgs
    ];
    userSettings = {
      # Nix settings
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      # R settings
      "r.rterm.linux" = "${pkgs.R}/bin/R"; # Absolute path to R
      "r.rpath.linux" = "${pkgs.R}/bin/R";
      "r.lsp.path" = "${pkgs.rPackages.languageserver}/library/languageserver";
      "r.lsp.enabled" = true;
      "r.lsp.args" = ["--vanilla"]; # Optional: Prevent loading user profiles
      "r.lsp.diagnostics" = true; # Enable linting for R code
    };
  };

  # This will make R automatically load the language server when running interactively.
  home.file.".Rprofile".text = ''
  if (interactive() && requireNamespace("languageserver", quietly = TRUE)) {
    library(languageserver)
  }
'';

  # Autostart SynologyDrive on startup
  home.file.".config/autostart/synology-drive.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Synology Drive
    Exec=/run/current-system/sw/bin/synology-drive
    X-GNOME-Autostart-enabled=true
  '';

  # Git settings
  programs.git = {
    enable = true;
    userName = "Bob Muit";
    userEmail = "bob@bobmuit.nl";
  };

  # Clone nixos-config git repo
  home.activation.cloneNixosConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${config.home.homeDirectory}/nixos-config/.git" ]; then
      git clone https://github.com/bobmuit/nixos-config.git "${config.home.homeDirectory}/nixos-config"
    fi
  '';

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

  # Gnome settings
  dconf.settings = {
    # Enable minimize and maximize buttons in gnome
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
      dock-position = "BOTTOM"; # Position the dock at the bottom
      dock-fixed = true; # Prevent the dock from auto-hiding
      extend-height = true; # Stretch the dock vertically
      intellihide-mode = "NONE"; # Disable intelligent auto-hide
      height-fraction = 1.0; # Set the height fraction to 1.0 for full height
      dash-max-icon-size = 32; # Set the maximum icon size
      panel-mode = true; # Enable panel mode to stretch horizontally
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}