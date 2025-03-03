{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "bobmuit";
  home.homeDirectory = "/home/bobmuit";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    gnomeExtensions.applications-menu
    
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    # neofetch
    # nnn # terminal file manager

    # # archives
     zip
    # xz
     unzip
    # p7zip

    # # utils
    # ripgrep # recursively searches directories for a regex pattern
    # jq # A lightweight and flexible command-line JSON processor
    # yq-go # yaml processor https://github.com/mikefarah/yq
    # eza # A modern replacement for ‘ls’
    # fzf # A command-line fuzzy finder

    # # networking tools
    # mtr # A network diagnostic tool
    # iperf3
    # dnsutils  # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing
    # ipcalc  # it is a calculator for the IPv4/v6 addresses

    # # misc
    # cowsay
    # file
    # which
    # tree
    # gnused
    # gnutar
    # gawk
    # zstd
    # gnupg

    # # nix related
    # #
    # # it provides the command `nom` works just like `nix`
    # # with more details log output
    # nix-output-monitor

    # # productivity
    # hugo # static site generator
    # glow # markdown previewer in terminal

    # btop  # replacement of htop/nmon
    # iotop # io monitoring
    # iftop # network monitoring

    # # system call monitoring
    # strace # system call monitoring
    # ltrace # library call monitoring
    # lsof # list open files

    # # system tools
    # sysstat
    # lm_sensors # for `sensors` command
    # ethtool
    # pciutils # lspci
    # usbutils # lsusb
  ];
  
  imports = [
    ../../home/programs/browsers.nix
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Bob Muit";
    userEmail = "bob@bobmuit.nl";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
  '';
  };

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

    # set some aliases, feel free to add more or remove some
    #shellAliases = {  
    #};

    # Enable minimize and maximize buttons in gnome
    dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "applications-menu@gnome-shell-extensions.gcampax.github.com" #Not yet operational
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