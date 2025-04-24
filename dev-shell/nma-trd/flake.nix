{
  description = "R Development Environment with Pandoc and Selected Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    # userRLib = "${builtins.getEnv "HOME"}/.local/share/R/library"; # A persistent path
    # homeDir = builtins.getEnv "HOME";
    # userRLib = "${homeDir}/.local/share/R/library"; 

    # Create a custom R with necessary packages bundled
    rWithPackages = pkgs.rWrapper.override {
      packages = with pkgs.rPackages; [
        # Core R tools
        jsonlite
        languageserver
        devtools

        # Data Manipulation & Analysis
        dplyr
        ggplot2
        readr
        tibble
        tidyr
        purrr
        stringr
        forcats
        readxl
        writexl
        openxlsx
        summarytools
        gridExtra
        rgl
        scales
        gtable

        # Meta-Analysis & Network Meta-Analysis
        meta
        netmeta
        # NMA

        # R Markdown & Reporting
        rmarkdown
        knitr
        tinytex
        # kableExtra

        # Other Tools
        # PRISMA2020
        RISmed
      ];
    };

  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        rWithPackages
        pandoc
        # Required for building dmetar
        cmake
        libxml2

        # To help installing packages
        pkg-config

        # Dependencies for costum packages
        zlib
        nodejs.libv8
        # Add more

        # Latex support
        texlive.combined.scheme-medium
      ];
    
      shellHook = ''
        echo "Nixpkgs git revision: $(nix eval --raw nixpkgs.rev)"

        # Make pkg-config available
        export PKG_CONFIG_PATH=${pkgs.zlib}/lib/pkgconfig:$PKG_CONFIG_PATH

        echo "R development environment loaded!"
        # Set up a writable user library path
        export R_LIBS_USER="$HOME/.local/share/R/library"
        mkdir -p "$R_LIBS_USER"
        export R_PROFILE_USER=$PWD/.Rprofile
        # export R_HOME=${rWithPackages}/lib/R
        export PATH=${rWithPackages}/bin:$PATH
        
        # Create a file that VSCode R extension can use to detect R
        mkdir -p .vscode
        echo "# R environment marker file for VSCode" > .vscode-R-environment
        echo "R_HOME=${rWithPackages}/lib/R" >> .vscode-R-environment
        echo "R_BINARY=${rWithPackages}/bin/R" >> .vscode-R-environment
        
        echo '#!/bin/bash
        # This script helps VSCode use the R from the nix shell
        nix develop -c R "$@"' > R-shell-wrapper.sh
        chmod +x R-shell-wrapper.sh

        # Create settings.json with recognition of custom R environment
        mkdir -p .vscode
        cat > .vscode/settings.json << 'EOF'
        {
          "r.alwaysUseActiveTerminal": true,
          "r.bracketedPaste": true,
          "r.sessionWatcher": true,
          "r.rterm.linux": "$${toString ./.}/R-shell-wrapper.sh",
          "r.lsp.enabled": true
        }
        EOF

        # # List of packages to check and install if needed
        # # These packages are unavailable in nixpkgs
        # PACKAGES_TO_INSTALL=(
        #   "NMA"
        #   "PRISMA2020"
        #   "kableExtra"
        # )

        # # Check and install packages if they're not already installed
        # echo "Checking for additional R packages..."
        # for pkg in "''${PACKAGES_TO_INSTALL[@]}"; do
        #   if ! R --quiet -e "library('$pkg')" 2>/dev/null; then
        #     echo "Installing $pkg package (this will only happen once)..."
        #     R --quiet -e "install.packages('$pkg', lib=Sys.getenv('R_LIBS_USER'), repos='https://cran.rstudio.com/')"
        #     echo "$pkg package installed successfully."
        #   else
        #     echo "$pkg package is already installed."
        #   fi
        # done

        # # Check and install GitHub packages if needed
        # if ! R --quiet -e "library('dmetar')" 2>/dev/null; then
        #   echo "Installing dmetar from GitHub (this will only happen once)..."
        #   R --quiet -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes', lib=Sys.getenv('R_LIBS_USER'), repos='https://cloud.r-project.org'); remotes::install_github('MathiasHarrer/dmetar', lib=Sys.getenv('R_LIBS_USER'))"
        #   echo "dmetar package installed successfully."
        # else
        #   echo "dmetar package is already installed."
        # fi

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt."
      '';
    };
  };
}