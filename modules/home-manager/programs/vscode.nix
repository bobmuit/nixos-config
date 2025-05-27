{ config, pkgs, ... }:

let
  vscode-utils = pkgs.vscode-utils;

  zotero-ext = vscode-utils.extensionFromVscodeMarketplace {
    pname = "zotero";
    version = "0.1.11";
    vscodeExtPublisher = "mblode";
    vscodeExtName = "zotero";
    vscodeExtUniqueId = "mblode.zotero";
    publisher = "mblode";
    name = "zotero";
    sha256 = "sha256-YN7CJqlE1otroS94LMNEZGbK/xKEY9jeJlbjqa0NBQc="; 
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      reditorsupport.r
      redhat.vscode-yaml
      yzhang.markdown-all-in-one
    ] ++ [ zotero-ext ];

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
