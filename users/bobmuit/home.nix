{ config, pkgs, inputs, ... }:

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
    # Desktop
    gnomeExtensions.applications-menu
    # Coding
    # N.B. Manage packages through flake.nix in project folder (dev env)
    R
    rPackages.languageserver
    
    # rstudio
    nixd
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

    # Configure just for bash
    initExtra = ''
      eval "$(just --completions bash)"
      alias j=just 
      alias ls="eza"
      alias ll="eza --long --all --git"
    '';

    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };
  
  # Starship shell prompt
  programs.starship.enable = true;

  # Joplin settings
  programs.joplin-desktop.enable = true;
  # TODO add configuration from Win10

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
        "applications-menu@gnome-shell-extensions.gcampax.github.com"
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