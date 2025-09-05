{ config, pkgs, inputs, lib, ... }:

{
  home.username = "bobmuit";
  home.homeDirectory = "/home/bobmuit";

  # Imported modules
  imports = [
    ../../modules/home-manager/programs/shells.nix
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Prevent dev-shells from being garbage collected
    # Run 'nix-dev' to enable dev-shell flake and create profile
    (pkgs.writeShellScriptBin "nix-dev" ''
        set -euo pipefail

        PROFILE_DIR="$HOME/.nix-devenvs"
        mkdir -p "$PROFILE_DIR"

        # Try to get Git project name
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
          GIT_ROOT=$(git rev-parse --show-toplevel)
          PROJECT_NAME=$(basename "$GIT_ROOT")
        else
          PROJECT_NAME="no-git"
        fi

        # Add short hash to the project name (for uniqueness)
        PROJECT_HASH=$(echo "$PWD" | sha256sum | cut -c1-8)

        # Combine git project name and hash
        PROFILE_PATH="$PROFILE_DIR/$PROJECT_NAME-$PROJECT_HASH"

        echo "Launching nix develop with profile: $PROFILE_PATH"
        exec nix develop --profile "$PROFILE_PATH" "$@"
    '')

  ];

  # This will make R automatically load the language server when running interactively.
  home.file.".Rprofile".text = ''
    if (interactive() && requireNamespace("languageserver", quietly = TRUE)) {
      library(languageserver)
    }
  '';

  # Git settings
  programs.git = {
    enable = true;
    userName = "Bob Muit";
    userEmail = "bob@bobmuit.nl";
  };

  # Clone nixos-config git repo
  home.activation.cloneNixosConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${config.home.homeDirectory}/nixos-config/.git" ]; then
      git clone https://github.com/bobmuit/nixos-config.git "${config.home.homeDirectory}/nixos-config"
    fi
  '';

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Managed via NixOS Home Manager module; no need to enable here.
}
