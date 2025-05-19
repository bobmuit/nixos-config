{ config, pkgs, secretsDir, ... }:

{
  sops.secrets."samba-synology" = {
    sopsFile = "${secretsDir}/samba-synology.env";
    owner = "root";
    group = "root";
    format = "dotenv";
    mode = "0600"; # Very important!
    path = "/etc/samba/samba-synology.ini";
  };
}