{
  description = "R Development Environment with Pandoc and Selected Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # Building packages from CRAN unavailable in nixpkgs
    # Create a custom kableExtra package
    kableExtra = pkgs.rPackages.buildRPackage {
      name = "kableExtra-1.4.0";
      pname = "kableExtra";
      version = "1.4.0";
      src = pkgs.fetchurl {
        url = "https://cran.r-project.org/src/contrib/kableExtra_1.4.0.tar.gz";
        sha256 = "02blaamz6xkdwgyvw6akjhn5fvwy8l24k7nwqj2id6g8qagwrqlg";
      };
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      propagatedBuildInputs = with pkgs.rPackages; [
        # Required imports
        knitr
        magrittr
        stringr
        xml2
        rmarkdown
        scales
        viridisLite
        htmltools
        rstudioapi
        digest
        svglite
        
        # Suggested packages
        magick
        tinytex
        formattable
        sparkline
        webshot2
        
        # Additional dependencies
        rvest
        readr
        rlang
        dplyr
        png
        jpeg
        base64enc
        highr
        evaluate
        glue
      ];
      meta = {
        homepage = "https://cran.r-project.org/package=kableExtra";
        license = pkgs.lib.licenses.mit;
        platforms = pkgs.lib.platforms.all;
      };
    };

    # Create a custom PRISMA2020 package
    prisma2020 = pkgs.rPackages.buildRPackage {
      name = "PRISMA2020-1.1.1";
      pname = "PRISMA2020";
      version = "1.1.1";
      src = pkgs.fetchurl {
        url = "https://cran.r-project.org/src/contrib/PRISMA2020_1.1.1.tar.gz";
        sha256 = "0jhf1kgcc29b8gsb42b3d5hyfzsa13lz9qgs104ynrzld94kqqwf";
      };
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      propagatedBuildInputs = with pkgs.rPackages; [
        # Required imports
        DiagrammeR
        DiagrammeRsvg
        htmltools
        htmlwidgets
        rsvg
        scales
        # stats # unavailable
        shiny
        shinyjs
        stringr
        # utils # unavailable
        xml2
        webp
        DT
        rio
        # tools # unavailable
        zip
      ];
      meta = {
        homepage = "https://cran.r-project.org/package=PRISMA2020";
        license = pkgs.lib.licenses.gpl2;
        platforms = pkgs.lib.platforms.all;
      };
    };

    # Create a custom NMA package
    nma = pkgs.rPackages.buildRPackage {
      name = "NMA-1.4-3";
      pname = "NMA";
      version = "1.4-3";
      src = pkgs.fetchurl {
        url = "https://cran.r-project.org/src/contrib/NMA_1.4-3.tar.gz";
        sha256 = "09y3arzw08054xb1y3nmnnzxybgjm2yyvkc530avpqkl1yrb1ap2";
      };
      nativeBuildInputs = with pkgs; [
        pkg-config
      ];
      propagatedBuildInputs = with pkgs.rPackages; [
        # Required imports
        # stats # unavailable
        # grid # unavailable
        MASS
        ggplot2
        metafor
        stringr
        forestplot
      ];
      meta = {
        homepage = "https://cran.r-project.org/package=NMA";
        license = pkgs.lib.licenses.gpl2;
        platforms = pkgs.lib.platforms.all;
      };
    };

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
        # NMA # Now using our custom build

        # R Markdown & Reporting
        rmarkdown
        knitr
        tinytex
      ] ++ [
        # Add our custom packages
        kableExtra
        prisma2020
        nma
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

        # Dependencies for custom packages
        # These could probaby be removed because now I am using buildRPackages
        zlib
        nodejs.libv8

        # Latex support
        texlive.combined.scheme-full
      ];
    
      shellHook = ''
        # Make pkg-config available
        export PKG_CONFIG_PATH=${pkgs.zlib}/lib/pkgconfig:$PKG_CONFIG_PATH

        echo "R development environment loaded!"
        
        # Set up R environment variables
        export R_LIBS_USER="$HOME/.local/share/R/library"
        export R_LIBS_SITE="${rWithPackages}/lib/R/library"
        export R_PROFILE_USER=$PWD/.Rprofile
        export PATH=${rWithPackages}/bin:$PATH
        export CURSOR_R_PATH="${rWithPackages}/bin/R"
        
        # Create necessary directories
        mkdir -p "$R_LIBS_USER"
        
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

        # Create a script to help Cursor find the R executable
        echo '#!/bin/bash
        # This script helps Cursor find the R executable
        if [ -n "$CURSOR_R_PATH" ]; then
          exec "$CURSOR_R_PATH" "$@"
        else
          exec "${rWithPackages}/bin/R" "$@"
        fi' > cursor-r-wrapper.sh
        chmod +x cursor-r-wrapper.sh

        # Create Cursor-specific settings
        mkdir -p .vscode
        cat > .vscode/cursor.json << 'EOF'
        {
          "r.rterm.linux": "$${toString ./.}/cursor-r-wrapper.sh",
          "r.rpath.linux": "${rWithPackages}/bin/R",
          "r.lsp.enabled": true,
          "r.alwaysUseActiveTerminal": true,
          "r.bracketedPaste": true,
          "r.sessionWatcher": true,
          "editor.formatOnSave": true,
          "editor.defaultFormatter": "r-lsp.r-lsp",
          "r.lsp.path": "${rWithPackages}/bin/R",
          "r.lsp.diagnostics": true,
          "r.lsp.completion": true,
          "r.lsp.hover": true,
          "r.lsp.signature": true,
          "r.libPaths": [
            "${rWithPackages}/lib/R/library",
            "$HOME/.local/share/R/library"
          ]
        }
        EOF

        # Create a timestamp file to track last successful installation
        INSTALL_TIMESTAMP="$HOME/.local/share/R/library/.last_install_timestamp"
        CURRENT_TIME=$(date +%s)

        # Only check for installations if timestamp file doesn't exist or is older than 1 day
        if [ ! -f "$INSTALL_TIMESTAMP" ] || [ $((CURRENT_TIME - $(cat "$INSTALL_TIMESTAMP"))) -gt 86400 ]; then
          # Check and install GitHub packages if needed
          if ! R --quiet -e "suppressWarnings(library('dmetar', quietly=TRUE, character.only=TRUE))" 2>/dev/null; then
            echo "Installing dmetar from GitHub..."
            R --quiet -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes', lib=Sys.getenv('R_LIBS_USER'), repos='https://cloud.r-project.org', quiet=TRUE); remotes::install_github('MathiasHarrer/dmetar', lib=Sys.getenv('R_LIBS_USER'), quiet=TRUE)"
            if [ $? -eq 0 ]; then
              echo "dmetar package installed successfully."
              # Update timestamp after successful installation
              echo "$CURRENT_TIME" > "$INSTALL_TIMESTAMP"
            else
              echo "Failed to install dmetar package."
            fi
          else
            echo "dmetar package is already installed."
            # Update timestamp since package is already installed
            echo "$CURRENT_TIME" > "$INSTALL_TIMESTAMP"
          fi
        else
          echo "Package installation check skipped (last check was less than 24 hours ago)"
        fi

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt."
        echo "To start Cursor in this development shell, type 'cursor .' at the prompt.
      '';
    };
  };
}