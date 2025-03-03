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

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # TODO: please change the hostname to your own
      nixos-dell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the configuration.nix in the current directory
          ./hosts/nixos-dell/configuration.nix

          # Use home-manager as a module to manage user configurations
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Enable backups
            home-manager.backupFileExtension = "backup";

            # Import the user-specific home-manager configuration from home.nix
            home-manager.users.bobmuit = import (./users/bobmuit/home.nix);

            # Optionally, you can pass additional arguments to home.nix via `extraSpecialArgs`
            # home-manager.extraSpecialArgs = ...;
          }
        ];
      };
    };
  };
}
