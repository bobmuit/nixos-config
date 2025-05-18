{ config, pkgs, ... }:

let
  sambaSecrets = pkgs.lib.importYAML config.sops.secrets."samba-synology".path;
in {
  sops.secrets."samba-synology" = {
    sopsFile = ./samba-synology.yaml;
    owner = "root";
    group = "root";
    format = "yaml";
    mode = "0600";
  };

  environment.etc."samba/samba-synology.ini".text = ''
    username = ${sambaSecrets.username}
    password = ${sambaSecrets.password}
  '';
}