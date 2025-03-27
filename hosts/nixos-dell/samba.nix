{ config, pkgs, ... }:

{
  # Enable samba
  services.samba = {
    enable = true;
    package = pkgs.samba;
  }; 

  # Add docker folder on Synology as network share
  fileSystems."/mnt/synology/docker" = {
    device = "//192.168.1.180/docker";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
    ];
  };

  # Add media folder on Synology as network share
  fileSystems."/mnt/synology/media" = {
    device = "//192.168.1.180/media";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
    ];
  };

  # Add marloes-bob folder on Synology as network share
  fileSystems."/mnt/synology/marloes-bob" = {
    device = "//192.168.1.180/marloes-bob";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
      "file_mode=0775"
      "dir_mode=0775"
      "noperm"            # Ignore server permissions
    ];
  };

  # Add bob-storage folder on Synology as network share
  fileSystems."/mnt/synology/bob-storage" = {
    device = "//192.168.1.180/bob-storage";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
      "file_mode=0775"
      "dir_mode=0775"
      "noperm"            # Ignore server permissions
    ];
  };

  # Add bob-storage folder on Synology as network share
  fileSystems."/mnt/nixos-pi/home" = {
    device = "//192.168.1.63/home";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/hosts/nixos-dell/smb-credentials-nixos-pi"
      "rw"
      "nofail" # Boot even if share fails to mount
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
      "file_mode=0775"
      "dir_mode=0775"
      "noperm"            # Ignore server permissions
    ];
  };

}