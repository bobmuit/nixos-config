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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, firefox-addons, ... }@inputs:
    let
      system = "x86_64-linux"; # Adjust for your architecture if necessary
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
      # Add this to enable 'home-manager switch':
      homeConfigurations.bobmuit = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [ ./users/bobmuit/home.nix ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}