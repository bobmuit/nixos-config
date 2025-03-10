# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      # ../../modules/nixos/programs/R.nix
      
      # Wireguard configuration
      # Issue that .conf file cant be found due to not being included in
      # repo. 
      # ./wireguard/default.nix

      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings = {
    # Enable flakes and the accompanying new nix command-line tool
    experimental-features = [ "nix-command" "flakes" ];

    # Auto deduplicate nix store
    auto-optimise-store = true; 

    # Increase download buffer size
    download-buffer-size = 104857600; # 100 MB (or adjust as needed)
  };
  

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-dell"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
  };
  
  # Enable samba
  services.samba = {
    enable = true;
    package = pkgs.samba;
  }; 

  # Add docker folder on Synology as network share
  fileSystems."/mnt/synology/docker" = {
    device = "//192.168.1.180/docker";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-syno"
      "rw"
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
    ];
  };

  # Enable WireGuard
  # networking.wireguard.enable = true; 

  # networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Disable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bobmuit = {
    isNormalUser = true;
    description = "Bob Muit";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
        
    # System
    gnomeExtensions.dash-to-dock
    home-manager

    # Work
    vmware-horizon-client
    zotero
    
    # Security
    bitwarden-desktop
    wireguard-tools
    # To add wireguard connection to NetworkManager, run
    # nmcli connection import type wireguard file configurationfile.conf
    
    # Homelab
    synology-drive-client
    cifs-utils #smb

    # Proton
    protonvpn-cli_2
    protonvpn-gui
    protonmail-desktop

    # Media 
    spotify
    vlc

    # Basic utilities
    neovim
    git

    # Productivity
    libreoffice-fresh
    kuro #Microsoft To Do

    # Browsers
    librewolf #TODO configure in Home-Manager
    ungoogled-chromium
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

    # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall = {
  #   allowedUDPPorts = [ 51820 ]; # Wireguard client
  # };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Configuration to enable WireGuard connection (disable rpfilter)
  # networking.firewall.checkReversePath = false; 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  #services.flatpak.enable = true;
  
  # Autoupdate
  system.autoUpgrade = {
    enable = true;
    flake = "github:nixos/nixpkgs/nixos-24.11"; # Adjust to match your repo
    dates = "weekly";
    randomizedDelaySec = "3600"; # Spread out updates to avoid server overload
  };

  # Automatic Garbage Collection
  nix.gc = {
  	automatic = true;
	  dates = "weekly";
	  options = "--delete-older-than 31d";
  };

}
