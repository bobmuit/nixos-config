{
  description = "Headless NixOS configuration for Raspberry Pi 4";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs, nixpkgs-unstable }: {
    nixosConfigurations.nixos-pi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Base SD image configuration
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        
        # Your custom configuration
        {
          # Set your hostname
          networking.hostName = "nixos-pi";
          
          # Essential for headless: Enable SSH server on boot
          services.openssh = {
            enable = true;
            settings.permitRootLogin = "no";
            settings.passwordAuthentication = false;
          };
          
          # User configuration with your SSH key
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "nixos"; # Will be used if SSH fails; change this!
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGc0lUn+zcewulF+LE8+j87Gb3lKVZkBHZcoPRmpsV0j"
            ];
          };
          
          # Enable sudo without password for wheel group (useful for headless)
          security.sudo.wheelNeedsPassword = false;

          # Network configuration (DHCP by default)
          networking = {
            networkmanager.enable = true;
            wireless.enable = false; # Disable wpa_supplicant
            firewall = {
              enable = true;
              allowedTCPPorts = [ 22 ];
            };
          };
          
          # Raspberry Pi specific configuration
          boot.loader.grub.enable = false;
          boot.loader.generic-extlinux-compatible.enable = true;
          boot.kernelPackages = nixpkgs.legacyPackages.aarch64-linux.linuxPackages_rpi4;
          
          # Hardware settings
          hardware.enableRedistributableFirmware = true;

          # Enable auto-upgrade and garbage collection
          system.autoUpgrade.enable = true;
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
          
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
          
          # Set timezone
          time.timeZone = "UTC";
          
          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # This ensures the configuration is activated on first boot
          system.stateVersion = "24.11";
        }
      ];
    };
    
    # Add a package output for the SD image
    packages.aarch64-linux.default = self.nixosConfigurations.nixos-pi.config.system.build.sdImage;
  };
}