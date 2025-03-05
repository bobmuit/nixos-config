{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";  # Keep nixpkgs consistent between flake and home-manager
    };
  };

  # outputs = inputs@{ nixpkgs, home-manager, ... }: {
  #   nixosConfigurations = {
  #     nixos-dell = nixpkgs.lib.nixosSystem {
  #       system = "x86_64-linux";
  #       modules = [
  #         # Import the configuration.nix in the current directory
  #         ./hosts/nixos-dell

  #         # Use home-manager as a module to manage user configurations
  #         home-manager.nixosModules.home-manager {
  #           home-manager.useGlobalPkgs = true;
  #           home-manager.useUserPackages = true;

  #           # Enable backups
  #           home-manager.backupFileExtension = "backup";

  #           # Import the user-specific home-manager configuration from home.nix
  #           home-manager.users.bobmuit = import (./users/bobmuit/home.nix);

  #           # Optionally, you can pass additional arguments to home.nix via `extraSpecialArgs`
  #           # home-manager.extraSpecialArgs = ...;

  #         homeConfigurations.bobmuit = home-manager.lib.homeManagerConfiguration {
  #           system = "x86_64-linux";
  #           pkgs = nixpkgs.legacyPackages.${system};
  #           extraSpecialArgs = { inherit inputs; };
  #           modules = [ ./home.nix ]; # Your Home Manager configuration
  #         };
  #         }
  #       ];
  #     };
  #   };
  # };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux"; # Adjust for your architecture if necessary
    in {
      nixosConfigurations.nixos-dell = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos-dell
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backups
            home-manager.backupFileExtension = "backup";

            home-manager.users.bobmuit = import ./users/bobmuit/home.nix; # Adjust to match your username
          }
        ];
      };

      homeConfigurations.bobmuit = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./users/bobmuit/home.nix ]; # Load your Home Manager config
        extraSpecialArgs = { inherit inputs; }; # Pass additional arguments if needed
      };
    };
}
