{ config, pkgs, ... }:

{
  home.username = "bobmuit";
  home.homeDirectory = "/home/bobmuit";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # gnomeExtensions.applications-menu  
  ];
  
  # Imported modules
  imports = [
    ../../modules/home-manager/programs/browsers.nix
    ../../modules/home-manager/programs/coding.nix
  ];
  
  # Nix autoformatter
  # programs.alejandra.enable = true;

  # Configuration for git
  programs.git = {
    enable = true;
    userName = "Bob Muit";
    userEmail = "bob@bobmuit.nl";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;

    # Add aliases using initExtra
    initExtra = ''
      alias hs="home-manager switch --flake ~/nixos-config#bobmuit"
      alias ns="nixos-rebuild switch --flake .#nixos-dell"
      alias nb="nixos-rebuild build --flake .#nixos-dell"
    '';
    
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };


      # set some aliases, feel free to add more or remove some
    #shellAliases = {  
    #};

    # Enable minimize and maximize buttons in gnome
    # Consider moving over to home-manager/desktop.nix
    dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        # "applications-menu@gnome-shell-extensions.gcampax.github.com" #Not yet operational
      ];
    };
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