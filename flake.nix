{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";  # Keep nixpkgs consistent between flake and home-manager
    };

    # Nix User Repository, used for Firefox add-ons
    nur = {
      url = "github:nix-community/NUR";
    };

  };

  outputs = { self, nixpkgs, home-manager, nur,  ... }@inputs:
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

            home-manager.users.bobmuit = import ./users/bobmuit ; # Adjust to match your username
            home-manager.extraSpecialArgs = { inherit (inputs) nixpkgs nur; }; 

          }
        ];
      };

      # homeConfigurations.bobmuit = home-manager.lib.homeManagerConfiguration {
      #   pkgs = nixpkgs.legacyPackages.${system};
      #   modules = [ ./users/bobmuit ]; # Load your Home Manager config
      #   specialArgs = { inherit inputs; }; # Pass additional arguments if needed
      # };
    };
}
