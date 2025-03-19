{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Keep nixpkgs consistent between flake and home-manager
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, firefox-addons, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux"; # For main system
      aarch64-system = "aarch64-linux"; # For the Raspberry Pi
    in {
      nixosConfigurations.nixos-dell = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true; # Optional: enable unfree packages
          };
        };
        modules = [
          ./hosts/nixos-dell
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backups
            home-manager.backupFileExtension = "backup";
            home-manager.users.bobmuit = import ./users/bobmuit/home.nix; # Adjust to match your username
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      
      # Add Raspberry Pi 4 configuration
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
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.backupFileExtension = "backup";
          #   home-manager.users.bobmuit = import ./users/bobmuit/home-pi.nix; # You can create a separate config for the Pi
          #   home-manager.extraSpecialArgs = { inherit inputs; };
          # }
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