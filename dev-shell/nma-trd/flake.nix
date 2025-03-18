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
        tidyverse
        dplyr
        stringr
        readxl
        writexl
        openxlsx
        summarytools
        gridExtra
        ggplot2
        rgl
        scales
        gtable

        # Meta-Analysis & Network Meta-Analysis
        meta
        netmeta
        NMA

        # R Markdown & Reporting
        rmarkdown
        knitr
        tinytex
        kableExtra

        # Other Tools
        PRISMA2020
        RISmed
      ];
    };

  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        rWithPackages # Use costum R with packages  
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
        echo "# R environment marker file for VSCode" > .vscode-R-environment
        echo "R_HOME=${rWithPackages}/lib/R" >> .vscode-R-environment
        echo "R_BINARY=${rWithPackages}/bin/R" >> .vscode-R-environment
        
        echo "Installing dmetar from GitHub (if not already installed)..."
        Rscript -e 'if (!requireNamespace("dmetar", quietly = TRUE)) { install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_github("MathiasHarrer/dmetar", lib=Sys.getenv("R_LIBS_USER")) }'

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt"
      '';
    };
  };
}
