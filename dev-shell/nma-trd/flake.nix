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
        jsonlite
        languageserver
        # Add other packages you need
      ];
    };

  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        R
        rPackages.languageserver  # Explicitly include languageserver
        rPackages.devtools  # Needed for GitHub installs
        rPackages.jsonlite
        rPackages.rlang
        pandoc

        # Required for building dmetar
        cmake 
        libxml2

        # Data Manipulation & Analysis
        rPackages.tidyverse
        rPackages.dplyr
        rPackages.stringr
        rPackages.readxl
        rPackages.writexl
        rPackages.openxlsx
        rPackages.summarytools
        rPackages.gridExtra
        rPackages.ggplot2
        rPackages.rgl
        rPackages.scales
        rPackages.gtable

        # Meta-Analysis & Network Meta-Analysis
        rPackages.meta
        rPackages.netmeta
        rPackages.NMA

        # R Markdown & Reporting
        rPackages.rmarkdown
        rPackages.knitr
        rPackages.tinytex
        rPackages.kableExtra

        # Other Tools
        rPackages.PRISMA2020
        rPackages.RISmed
      ];

      shellHook = ''
        echo "R development environment loaded!"
        # Set up a writable user library path
        mkdir -p ${userRLib}
        export R_LIBS_USER=${userRLib} # Set R user library
        export R_PROFILE_USER=$PWD/.Rprofile
        export R_HOME=${pkgs.R}/lib/R
        export PATH=${pkgs.R}/bin:$PATH
        
        # Create a file that VSCode R extension can use to detect R
        echo "# R environment marker file for VSCode" > .vscode-R-environment
        echo "R_HOME=${pkgs.R}/lib/R" >> .vscode-R-environment
        echo "R_BINARY=${pkgs.R}/bin/R" >> .vscode-R-environment
        
        echo "Installing dmetar from GitHub (if not already installed)..."
        Rscript -e 'if (!requireNamespace("dmetar", quietly = TRUE)) { install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_github("MathiasHarrer/dmetar", lib=Sys.getenv("R_LIBS_USER")) }'

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt"
      '';
    };
  };
}
