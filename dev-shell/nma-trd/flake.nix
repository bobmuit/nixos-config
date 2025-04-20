{
  description = "R Development Environment with Pandoc and Selected Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
        # tidyverse
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

        # Simplified texlive approach to avoid derivation errors
        # texlive.combined.scheme-medium

        # Add these packages for XeLaTeX and natbib support
        # (texlive.combine {
        #   inherit (texlive) 
        #     scheme-medium    # Base packages
        #     xetex           # XeLaTeX
        #     fontspec        # Font handling for XeLaTeX
        #     natbib          # Bibliography management
        #     biblatex        # Modern bibliography management
        #     biber           # Bibliography processor for biblatex
        #     latexmk         # Build tool for LaTeX
            
        #     # Common dependencies for academic documents
        #     amsmath
        #     amscls
        #     mathtools
        #     unicode-math    # Unicode math support for XeLaTeX
            
        #     # For handling of PDF graphics and links
        #     hyperref
            
        #     # Language and font support
        #     babel
        #     polyglossia     # Multilingual typesetting with XeLaTeX
            
        #     # Tables support
        #     booktabs
        #     # longtable
        #     # tabularx
            
        #     # Additional commonly needed packages
        #     xcolor          # Color support
        #     caption
        #     setspace        # Line spacing
        #     etoolbox
        #     koma-script     # Modern document classes
        #     geometry        # Page layout
            
        #     # If you need specific styles for citations
        #     elsarticle      # Elsevier journals
        #     acmart;          # ACM publications
        # })

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
        
        # Temporarily disabled ####
        # echo "Installing dmetar from GitHub (if not already installed)..."
        # Rscript -e 'if (!requireNamespace("dmetar", quietly = TRUE)) { install.packages("remotes", repos="https://cloud.r-project.org"); remotes::install_github("MathiasHarrer/dmetar", lib=Sys.getenv("R_LIBS_USER")) }'
        echo "Please note that dmetar is disabled."

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

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt."
      '';
    };
  };
}