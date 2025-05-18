{ config, pkgs, ... }:

{
  # Enable samba support
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # Enable samba
  services.samba = {
    enable = true;
    package = pkgs.samba;
  }; 

  sops.secrets."samba-synology" = {
    sopsFile = ../../../../secrets/nixos-dell/samba-synology.ini;
    owner = "root";
    group = "root";
    format = "ini";
    mode = "0600"; # Very important!
    path = "/etc/samba/samba-synology.ini";
  };

  # Create the mount directories
  systemd.tmpfiles.rules = [
    "d /mnt/synology 0755 root root -"
    "d /mnt/synology/docker 0755 root root -"
    "d /mnt/synology/marloes-bob 0755 root root -"
    "d /mnt/synology/bob-storage 0755 root root -"
    "d /mnt/synology/photo 0755 root root -"
  ];

  # Add docker folder on Synology as network share
  fileSystems."/mnt/synology/docker" = {
    device = "//192.168.1.180/docker";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/home/bobmuit/nixos-config/modules/nixos/services/smb-client/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "noauto"  # Prevents automatic mounting at boot
      "x-systemd.automount"  # Mounts only when accessed
      "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
      "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
    ];
  };

  # Add media folder on Synology as network share
  # fileSystems."/mnt/synology/media" = {
  #   device = "//192.168.1.180/usbshare1/media";  # Replace with your server IP and share
  #   fsType = "cifs";
  #   options = [
  #     "credentials=/home/bobmuit/nixos-config/modules/nixos/services/smb-client/smb-credentials-syno"
  #     "rw"
  #     "nofail" # Boot even if share fails to mount
  #     "x-systemd.automount"  # Mounts only when accessed
  #     "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
  #     "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
  #     "iocharset=utf8"
  #     "vers=3.0"  # Adjust based on your server's supported SMB version
  #   ];
  # };

  # Add marloes-bob folder on Synology as network share
  fileSystems."/mnt/synology/marloes-bob" = {
    device = "//192.168.1.180/marloes-bob";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=/etc/samba/samba-synology.ini"
      "rw"
      "nofail" # Boot even if share fails to mount
      "noauto"  # Prevents automatic mounting at boot
      "x-systemd.automount"  # Mounts only when accessed
      "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
      "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
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
      "credentials=//home/bobmuit/nixos-config/modules/nixos/services/smb-client/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "noauto"  # Prevents automatic mounting at boot
      "x-systemd.automount"  # Mounts only when accessed
      "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
      "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
      "iocharset=utf8"
      "vers=3.0"  # Adjust based on your server's supported SMB version
      "uid=1000"
      "gid=100"
      "file_mode=0775"
      "dir_mode=0775"
      "noperm"            # Ignore server permissions
    ];
  };

  # Add photo folder on Synology as network share
  fileSystems."/mnt/synology/photo" = {
    device = "//192.168.1.180/photo";  # Replace with your server IP and share
    fsType = "cifs";
    options = [
      "credentials=//home/bobmuit/nixos-config/modules/nixos/services/smb-client/smb-credentials-syno"
      "rw"
      "nofail" # Boot even if share fails to mount
      "noauto"  # Prevents automatic mounting at boot
      "x-systemd.automount"  # Mounts only when accessed
      "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
      "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
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
  #fileSystems."/mnt/nixos-pi/home" = {
  #  device = "//192.168.1.63/home";  # Replace with your server IP and share
  #  fsType = "cifs";
  #  options = [
  #    "credentials=/home/bobmuit/nixos-config/modules/nixos/services/smb-client/smb-credentials-nixos-pi"
  #    "rw"
  #    "nofail" # Boot even if share fails to mount
  # "noauto"  # Prevents automatic mounting at boot
  #      "x-systemd.automount"  # Mounts only when accessed
  #     "x-systemd.requires=network-online.target"  # Ensures network is up before mounting
  #      "x-systemd.idle-timeout=600"  # Unmounts after 10 minutes of inactivity
  #    "iocharset=utf8"
  #    "vers=3.0"  # Adjust based on your server's supported SMB version
  #    "uid=1000"
  #    "gid=100"
  #    "file_mode=0775"
  #    "dir_mode=0775"
  #    "noperm"            # Ignore server permissions
  #  ];
  #};

}
