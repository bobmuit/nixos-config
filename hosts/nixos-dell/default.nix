# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include CLI utilities
      ../../modules/nixos/programs/utilities.nix

      # Include samba shares
      ../../modules/nixos/services/smb-client/default.nix
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

  # Disable Plymouth for faster boot times
  boot.plymouth.enable = false;
  # boot.plymouth.theme = "spinner";

    # Enable swap
    swapDevices = [
        {
            device = "/swapfile";
            size = 4096; # in MB, optional if already created
        }
    ];

  networking.hostName = "nixos-dell"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
  };
  
  # Boot should not wait for NetworkManager to start
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # allow exit node use
    extraUpFlags = [ "--accept-routes" ]; # accept subnet routing
  };

  # Set DNS nameservers to a combination of
  # nixos-pi over Tailscale
  # and synology locally
  # networking.nameservers = ["100.104.67.42" "192.168.1.2"]; 

  # Set DNS to common nameservers, bypassing pi-hole
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

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

  # Disable unnecessary GNOME services
  systemd.user.services.gnome-remote-desktop.enable = false; # not using RDP
  systemd.user.services.gnome-software-service.enable = false; # updates by Nix
  systemd.user.services.gnome-software-daemon.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Disable CUPS to print documents.
  services.printing.enable = false;

  # Disable PulseAudio (replaced by PipeWire)
  hardware.pulseaudio.enable = false;

  # Enable real-time privileges (recommended)
  security.rtkit.enable = true;

  # PipeWire with WirePlumber
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # optional, useful for advanced apps
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Prolonge longetivity of SSD by periodically cleaning up blocks
  services.fstrim.enable = true;
  
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
        
    # Desktop
    gnomeExtensions.dash-to-dock
    gnome-menus

    # Home-manager
    home-manager

    # Work
    vmware-horizon-client
    zotero
    teams-for-linux
    
    # Coding
    # N.B. Manage packages through flake.nix in project folder (dev env)
    pkgs-unstable.code-cursor
    R
    rPackages.languageserver
    nixd

    # Security
    pkgs-unstable.bitwarden-desktop
    tailscale
    
    # Homelab
    synology-drive-client
    evolution # for accessing caldav

    # Proton
    protonvpn-cli_2
    protonvpn-gui
    pkgs-unstable.protonmail-desktop

    # Media 
    spotify
    spotify-player
    vlc

    # Chat
    signal-desktop

    # Productivity
    libreoffice-fresh
    hunspell
    hunspellDicts.nl_NL
    hunspellDicts.en_US # For English (US)
  # hunspellDicts.en_GB # For English (UK), 

    kuro #Microsoft To Do

    # Browsers
    ungoogled-chromium

    # Flatpak GUI
    gnome-software
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

  # Enable flatpak
  services.flatpak.enable = true;

  # Enable flathub
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Autoupdate
  # system.autoUpgrade = {
  #   enable = true;
  #   flake = "github:nixos/nixpkgs/nixos-24.11";
  #   dates = "weekly";
  # };

  # Automatic Garbage Collection
  nix.gc = {
  	automatic = true;
	  dates = "weekly";
	  options = "--delete-older-than 7d";
  };

}
