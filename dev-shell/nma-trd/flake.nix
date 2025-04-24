{
  description = "R Development Environment with Pandoc and Selected Packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

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
        # NMA # Not available in nixpkgs

        # R Markdown & Reporting
        rmarkdown
        knitr
        tinytex
        # kableExtra # Not available in nixpkgs

        # Other Tools
        # PRISMA2020 # Not available in nixpkgs
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

        # Dependencies for custom packages
        zlib
        nodejs.libv8

        # Latex support
        texlive.combined.scheme-medium
      ];
    
      shellHook = ''
        # Make pkg-config available
        export PKG_CONFIG_PATH=${pkgs.zlib}/lib/pkgconfig:$PKG_CONFIG_PATH

        echo "R development environment loaded!"
        
        # Set up R environment variables
        export R_HOME=${rWithPackages}/lib/R
        export R_LIBS_USER="$HOME/.local/share/R/library"
        export R_LIBS_SITE="${rWithPackages}/lib/R/library"
        export R_PROFILE_USER=$PWD/.Rprofile
        export PATH=${rWithPackages}/bin:$PATH
        export CURSOR_R_PATH="${rWithPackages}/bin/R"
        
        # Create necessary directories
        mkdir -p "$R_LIBS_USER"
        
        # Install jsonlite in user library if not already installed
        echo "Ensuring jsonlite is installed in user library..."
        R --quiet -e 'if (!requireNamespace("jsonlite", quietly = TRUE)) { 
          install.packages("jsonlite", 
                          lib=Sys.getenv("R_LIBS_USER"), 
                          repos="https://cloud.r-project.org", 
                          quiet=TRUE,
                          dependencies=TRUE) 
        }'
        
        # Verify jsonlite installation
        echo "Verifying jsonlite installation..."
        R --quiet -e 'if (!requireNamespace("jsonlite", quietly = TRUE)) { 
          stop("Failed to install jsonlite package") 
        } else { 
          cat("jsonlite package is installed and available\n") 
        }'
        
        # Force install jsonlite in user library to ensure it's available
        echo "Force installing jsonlite in user library..."
        R --quiet -e 'install.packages("jsonlite", 
                                      lib=Sys.getenv("R_LIBS_USER"), 
                                      repos="https://cloud.r-project.org", 
                                      quiet=TRUE,
                                      dependencies=TRUE)'
        
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

        # List of packages to check and install if needed
        # These packages are unavailable in nixpkgs
        PACKAGES_TO_INSTALL=(
          "NMA"
          # "PRISMA2020" # Endless build errors
          # "kableExtra" # Endless build errors
        )

        # Create a timestamp file to track last successful installation
        INSTALL_TIMESTAMP="$HOME/.local/share/R/library/.last_install_timestamp"
        CURRENT_TIME=$(date +%s)

        # Only check for installations if timestamp file doesn't exist or is older than 1 day
        # Use rm -f ~/.local/share/R/library/.last_install_timestamp to force reinstallation
        if [ ! -f "$INSTALL_TIMESTAMP" ] || [ $((CURRENT_TIME - $(cat "$INSTALL_TIMESTAMP"))) -gt 86400 ]; then
          echo "Checking for additional R packages..."
          for pkg in "''${PACKAGES_TO_INSTALL[@]}"; do
            if ! R --quiet -e "suppressWarnings(library('$pkg', quietly=TRUE, character.only=TRUE))" 2>/dev/null; then
              echo "Installing $pkg package..."
              R --quiet -e "install.packages('$pkg', lib=Sys.getenv('R_LIBS_USER'), repos='https://cran.rstudio.com/', quiet=TRUE)"
              if [ $? -eq 0 ]; then
                echo "$pkg package installed successfully."
              else
                echo "Failed to install $pkg package."
              fi
            else
              echo "$pkg package is already installed."
            fi
          done

          # Check and install GitHub packages if needed
          if ! R --quiet -e "suppressWarnings(library('dmetar', quietly=TRUE, character.only=TRUE))" 2>/dev/null; then
            echo "Installing dmetar from GitHub..."
            R --quiet -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes', lib=Sys.getenv('R_LIBS_USER'), repos='https://cloud.r-project.org', quiet=TRUE); remotes::install_github('MathiasHarrer/dmetar', lib=Sys.getenv('R_LIBS_USER'), quiet=TRUE)"
            if [ $? -eq 0 ]; then
              echo "dmetar package installed successfully."
            else
              echo "Failed to install dmetar package."
            fi
          else
            echo "dmetar package is already installed."
          fi

          # Update timestamp after successful installation
          echo "$CURRENT_TIME" > "$INSTALL_TIMESTAMP"
        else
          echo "Package installation check skipped (last check was less than 24 hours ago)"
        fi

        # Don't automatically start R
        echo "To start R, type 'R' at the prompt."
      '';
    };
  };
}