{ config, pkgs, ... }:

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
    # ../../modules/home-manager/programs/coding.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # gnomeExtensions.applications-menu  

    # Coding
    # N.B. Manage packages through flake.nix in project folder (dev env)
    R 
    rstudio
    nixd
  ];
  
  # VSCodium settings
  programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide           # Nix language support extension
        reditorsupport.r              # R Language
        zaaack.markdown-editor  # Add the Markdown Editor extension
        redhat.vscode-yaml           # Add the YAML support extension
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;  # Enable Nix language server
        "nix.serverPath" = "nixd";          # Path to the Nix language server
        "nix.serverSettings" = {
          "nixd" = {
            # Additional settings for the Nix language server can go here
          };
        "r.rterm.linux" = "/usr/bin/R";  # Path to the R executable (adjust if necessary)
        "r.rpath.linux" = "/usr/bin/R";   # Specify path for the R Language Server
        "r.lsp.args" = ["--vanilla"];     # Optional: Command line arguments for R
        "r.lsp.diagnostics" = true;        # Enable linting of R code
        };  
      };  
    };

  # Nix autoformatter
  # programs.alejandra.enable = true;

  # Git settings
  programs.git = {
    enable = true;
    userName = "Bob Muit";
    userEmail = "bob@bobmuit.nl";
  };

  # Bash settings
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # Add aliases using initExtra
    initExtra = ''
      alias hs="home-manager switch --flake ~/nixos-config#bobmuit"
      alias ns="sudo nixos-rebuild switch --flake .#nixos-dell"
      alias nb="sudo nixos-rebuild build --flake .#nixos-dell"
    '';
    
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };
  
  # Joplin settings
  programs.joplin-desktop.enable = true;

  # Gnome settings
  dconf.settings = {
    # Enable minimize and maximize buttons in gnome
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    
    # Enable extensions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        # "applications-menu@gnome-shell-extensions.gcampax.github.com" #Not yet operational
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