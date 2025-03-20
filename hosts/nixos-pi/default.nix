# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# Add network share for nixos-config and/or pi-hole config
# Add tailscale
# Add other useful things from nixos-dell
# Fix networking

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker"]; # Enable ‘sudo’ for the user.
    initialPassword = "nixos"; # Will be used if SSH fails; change this!
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc0lUn+zcewulF+LE8+j87Gb3lKVZkBHZcoPRmpsV0j"
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Server packages
    docker-compose

    # SysAdmin tools
    vim
    wget
    git
    tmux
    at
    tree
    samba
  ];

  # Enable at service
  services.atd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # services.openssh.settings.passwordAuthentication = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable rootless containers to use privileged ports for pihole
  # Required for podman, but maybe not docker
  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 53;
  };

  # Disable resolved because pihole needs :53
  services.resolved.enable = false;

  # Manually configure DNS server because resolved was disabled
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 8.8.8.8
  '';

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server"; # Allows the machine to act as a subnet router and DNS server
    openFirewall = true; # Opens required firewall ports for Tailscale
  };

  # Networking configuration
  networking = {
    hostName = "nixos-pi"; # Define your hostname.
    usePredictableInterfaceNames = false; # Disable systemd's default renaming

    interfaces.eth0 = {
      # Enable DHCP on eth0
      useDHCP = true;
      # Fallback static IP configuration in case DHCP fails
      ipv4.addresses = [{
        address = "192.168.1.63";  # Choose an appropriate static IP
        prefixLength = 24;
      }];
    };

    # Disable NetworkManager
    networkmanager.enable = false;

    # Enable systemd-networkd
    useNetworkd = true;

    # Disable wpa_supplicant
    wireless.enable = false; 

        # Enable firewall but allow: ssh
    firewall = {
      enable = true;  # Enable the firewall

      # Allow UDP traffic on port 53 for DNS
      allowedUDPPorts = [ 53 ];

      # Allow TCP traffic on ports:
      # - 22: SSH access
      # - 53: DNS service
      # - 80: HTTP for Pi-hole web interface
      # - 443: HTTPS for Pi-hole web interface
      allowedTCPPorts = [ 22 53 80 443 ];
    };
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # System state version (usually you don't need to change this)
  system.stateVersion = "24.11"; # Did you read the comment?c
}
