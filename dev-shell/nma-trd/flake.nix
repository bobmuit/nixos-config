{
  description = "R Development Environment with Pandoc and Selected Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    userRLib = "$HOME/R/lib";  # Define a writable directory for R packages

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
      ];
    
      shellHook = ''
        echo "R development environment loaded!"
        # Set up a writable user library path
        mkdir -p ${userRLib}
        export R_LIBS_USER=${userRLib} # Set R user library
        export R_PROFILE_USER=$PWD/.Rprofile
        export R_HOME=${rWithPackages}/lib/R
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

        # List of packages to check and install if needed
        # These packages are unavailable in nixpkgs
        PACKAGES_TO_INSTALL=(
          "NMA"
          "PRISMA2020"
          "kableExtra"
        )

        # Check and install packages if they're not already installed
        echo "Checking for additional R packages..."
        for pkg in "''${PACKAGES_TO_INSTALL[@]}"; do
          if ! R --quiet -e "library('$pkg')" 2>/dev/null; then
            echo "Installing $pkg package (this will only happen once)..."
            R --quiet -e "install.packages('$pkg', repos='https://cran.rstudio.com/')"
            echo "$pkg package installed successfully."
          else
            echo "$pkg package is already installed."
          fi
        done

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt."
      '';
    };
  };
}