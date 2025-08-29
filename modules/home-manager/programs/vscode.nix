{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    # Manage extensions through VSCode itself instead of through Nix
    mutableExtensionsDir = true;

    profiles.default.userSettings = {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "r.rterm.linux" = "${pkgs.R}/bin/R";
      "r.rpath.linux" = "${pkgs.R}/bin/R";
      "r.lsp.path" = "${pkgs.rPackages.languageserver}/library/languageserver";
      "r.lsp.enabled" = true;
      "r.lsp.args" = ["--vanilla"];
      "r.lsp.diagnostics" = true;
      "editor.wordWrap" = "on";
    };
  };
}