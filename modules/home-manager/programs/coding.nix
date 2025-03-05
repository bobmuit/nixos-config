{
  pkgs,
  config,
  #username,
  ...
}: {
  home.packages = with pkgs; [
    rstudio
    nixd
  ];
  
  programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide           # Nix language support extension
        reditorsupport.r              # R Language
        zaaack.markdown-editor  # Add the Markdown Editor extension
        redhat.vscode-yaml           # Add the YAML support extension
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;  # Enable Nix language server
        "nix.serverPath" = "nixd";          # Path to the Nix language server
        "nix.serverSettings" = {
          "nixd" = {
            # Additional settings for the Nix language server can go here
          };
        "r.rterm.linux" = "/usr/bin/R";  # Path to the R executable (adjust if necessary)
        "r.rpath.linux" = "/usr/bin/R";   # Specify path for the R Language Server
        "r.lsp.args" = ["--vanilla"];     # Optional: Command line arguments for R
        "r.lsp.diagnostics" = true;        # Enable linting of R code
        };  
      };  
    };
}