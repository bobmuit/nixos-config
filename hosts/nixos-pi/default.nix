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

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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
    extraGroups = [ "wheel" "podman"]; # Enable ‘sudo’ for the user.
    initialPassword = "nixos"; # Will be used if SSH fails; change this!
    openssh.authorizedKeys.keys = [
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc0lUn+zcewulF+LE8+j87Gb3lKVZkBHZcoPRmpsV0j"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # SysAdmin tools
    vim
    wget
    git
    tmux
    at

  ];

  # Enable at
  services.atd.enable = true;

  # Enable podman and configure OCI containers
  virtualisation.containers.enable = true;

  virtualisation.podman = {
    enable = true;
    # Create a `docker` alias for podman
    dockerCompat = true;
    # Required for containers to communicate
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    pihole = {
      image = "pihole/pihole:latest";
      autoStart = true;
      ports = [
        "53:53/tcp"   # DNS port (TCP) - available to network
        "53:53/udp"   # DNS port (UDP) - available to network
        "80:80/tcp"   # Web interface (HTTP)
        "443:443/tcp" # Web interface (HTTPS)
      ];
      volumes = [
        "/var/lib/containers/pihole/pihole:/etc/pihole"
        "/var/lib/containers/pihole/dnsmasq.d:/etc/dnsmasq.d"
      ];
      environment = {
        TZ = "Europe/London";
        WEBPASSWORD = builtins.readFile /home/nixos/nixos-config/hosts/nixos-pi/pihole-credentials;
        DNS1 = "1.1.1.1";
        DNS2 = "8.8.8.8";
        SERVERIP = "192.168.1.67";  # Pi's IP address
        DNSMASQ_USER = "root";
        DNSMASQ_LISTENING = "all";  # This will listen on all interfaces including VPN subnets
      };
      extraOptions = [
        "--hostname=pihole"
        "--dns=127.0.0.1"
        "--dns=8.8.8.8"
        "--cap-add=NET_ADMIN"  # Required for network-related operations
      ];
    };
  };

  # Make sure to create the directory for volumes
  system.activationScripts = {
    createPiholeDirectories = {
      text = ''
        mkdir -p /var/lib/containers/pihole/pihole
        mkdir -p /var/lib/containers/pihole/dnsmasq.d
      '';
      deps = [];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # services.openssh.settings.passwordAuthentication = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

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

    # Explicit DNS settings
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # Disable NetworkManager
    networkmanager.enable = false;

    # Enable systemd-networkd
    useNetworkd = true;

    # Disable wpa_supplicant
    wireless.enable = false; 

    # Enable firewall but allow: ssh
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Force eth0 via udev
  services.udev.extraRules = ''
    # Force eth0 naming with high priority (00-)
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="dc:a6:32:98:62:96", KERNEL=="end*", NAME="eth0", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/subsystem/net/devices/eth0"
  '';

  # Configure systemd-networkd to not try to set hostname
  systemd.services.systemd-networkd.serviceConfig = {
    CapabilityBoundingSet = "~CAP_SYS_ADMIN";
  };

  # Add kernel parameters to force traditional naming
  boot.kernelParams = [ "net.ifnames=0" "biosdevname=0" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  # Garbage collection
  nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
}

