# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4

# CUrrently on fkms consider kms
# Currently on modesetting, consider vc4
# Check mesa drivers for applicability

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Include CLI utilities
      ../../modules/nixos/programs/utilities.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible = {
        enable = true;
      };
    };
    # Enable HDMI CEC at kernel level
    kernelModules = [ 
      "cec" 
      "cec_gpio" 
    ];
    # Enable audio devices on RPi
    kernelParams = [ 
      "snd_bcm2835.enable_hdmi=1" 
      "snd_bcm2835.enable_headphones=1" 
    ];
  };

  # Enable fkms (not kms)
  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      fkms-3d.enable = true;
    };
    deviceTree = lib.mkForce {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    # Enable video hardware acceleration
    graphics = {
      enable = true;
      package = pkgs.mesa.drivers;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  environment.variables = {
    # Allow hardware accelerated OpenGL
    LIBGL_ALWAYS_SOFTWARE = "0";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.kodi.enable = true;

    # Optional: set resolution, etc.
    # videoDrivers = [ "vc4" ]; # kernel DRM driver
    videoDrivers = [ "modesetting" ]; # X11 driver
    # videoDrivers = [ "fbdev" ] # In case kms is used
  };

  # Allow autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };
  
  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound
  hardware.pulseaudio.enable = false;  # Disable PulseAudio
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;  # Enable PulseAudio compatibility for PipeWire  

    # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "video"]; # Enable ‘sudo’ for the user.
    # initialPassword = "nixos"; # Will be used if SSH fails; change this!
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc0lUn+zcewulF+LE8+j87Gb3lKVZkBHZcoPRmpsV0j"
    ];
  };

  # Add the sudoers rule for passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Server packages
    docker-compose

    # Media packages
    kodi
    kodiPlugins.jellyfin
    libcec # enables HDMI CEC

    # Tools and libraries for interacting with Raspberry Pi-specific hardware and features.
    libraspberrypi

    # Bootloader and firmware EEPROM for Raspberry Pi 4
    raspberrypi-eeprom
  ];

  # Add udev rule for Kodi hardware acceleration
  # Add udev rule for allowing Kodi access to HDMI CEC
  # Add udev rule access to the vchiq device, which is necessary for CEC communication on Raspberry Pi devices
  services.udev.extraRules = ''
    KERNEL=="dma_heap/linux,cma", MODE="0666"
    KERNEL=="cec[0-9]*", GROUP="video", MODE="0660"
    KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
  '';

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