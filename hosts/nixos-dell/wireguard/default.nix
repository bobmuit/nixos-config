{ config, pkgs, lib, ... }:

let
  # wireguardConf = "./wg-conf/SB42.conf"; 
  wireguardConf = "./wg-conf/NixBob-NL-647.conf"; 
in {
  # Ensure NetworkManager is enabled
  networking.networkmanager.enable = true;
  
  # Install necessary packages
  environment.systemPackages = with pkgs; [
    wireguard-tools
    # networkmanagerapplet # Optional: adds system tray icon
  ];
  
  # Import WireGuard configuration into NetworkManager
  systemd.services.import-wireguard = {
    description = "Import WireGuard configuration into NetworkManager";
    after = [ "network-manager.service" ]; # Correct service name
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.networkmanager ]; # Add to PATH
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.networkmanager}/bin/nmcli connection import type wireguard file ${wireguardConf}'";
      RemainAfterExit = true;
    };
  };
}