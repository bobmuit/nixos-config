{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Keep nixpkgs consistent between flake and home-manager
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };   
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, firefox-addons, nixos-hardware, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      aarch64-system = "aarch64-linux"; # For the Raspberry Pi
    in {

      # Laptop Bob configuration
      # Please note that this system is running unstable for default packages
      nixosConfigurations.nixos-dell = inputs.nixpkgs-unstable.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          pkgs-stable = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # Optional: enable unfree packages
          };
        };
        modules = [
          ./hosts/nixos-dell
          nixos-hardware.nixosModules.dell-latitude-7490
          sops-nix.nixosModules.sops

          home-manager.nixosModules.home-manager
          {
            # Pass sops-nix secretsDir as argument to all modules
            _module.args.secretsDir = ./secrets/nixos-dell;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backups
            home-manager.backupFileExtension = "backup-$(date +%Y%m%d-%H%M%S)";
            home-manager.users.bobmuit = import ./users/bobmuit/home.nix; # Adjust to match your username
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      
      # Raspberry Pi 4 configuration
      nixosConfigurations.nixos-pi = nixpkgs.lib.nixosSystem {
        system = aarch64-system;
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = aarch64-system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/nixos-pi
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };

      # Nixos-asus
      nixosConfigurations.nixos-asus = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/nixos-asus
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                tailscale = prev.tailscale.overrideAttrs (old: {
                  doCheck = false;
                });
              })
            ];
          })
        ];
      };
      
      # Home manager configurations
      homeConfigurations.bobmuit = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [ ./users/bobmuit/home.nix ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}