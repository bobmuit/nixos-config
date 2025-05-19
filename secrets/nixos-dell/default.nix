{ config, pkgs, secretsDir, ... }:

{
  # Adding sops package to encrypt/decrypt secrets
  environment.systemPackages = with pkgs; [
    sops
  ];

  # Defining sops-nix keyfile
  sops.age.keyFile = "/etc/sops/age/key.txt";

  # Making the location of the keyfile available in the shell
  environment.variables.SOPS_AGE_KEY_FILE = "/etc/sops/age/key.txt";
  
  # Credentials for accessing samba shares on synology as bobmuit
  sops.secrets."samba-synology" = {
    sopsFile = "${secretsDir}/samba-synology.env";
    owner = "root";
    group = "root";
    format = "dotenv";
    mode = "0600"; # Very important!
    path = "/etc/samba/samba-synology.ini";
  };
}