 # Create a custom NetworkManager configuration file to disable auto-activation of VPN connections
  environment.etc."NetworkManager/conf.d/90-vpn-no-autoconnect.conf".text = ''
  [connection-vpn]
  vpn.autoconnect=false
  '';

  # Network manager system tray
  programs.nm-applet.enable = true;
  
  # Configuration to enable WireGuard connection (alter rpfilter)
  networking.firewall.checkReversePath = "loose"; 

  # Import WireGuard config from .conf file
  systemd.services.import-wireguard-config = {
    description = "Import WireGuard config to NetworkManager";
    after = [ "network-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.networkmanager ];
    script = ''
      # Check if connections already exist, if so, remove them first
      if nmcli connection show | grep -q "ProtonVPN"; then
        nmcli connection delete "ProtonVPN"
      fi
      if nmcli connection show | grep -q "SB42"; then
        nmcli connection delete "SB42"
      fi
      
      # Import connections with auto-connect disabled
      nmcli connection import type wireguard file /home/bobmuit/nixos-config/hosts/nixos-dell/wg-conf/ProtonVPN.conf
      nmcli connection modify "ProtonVPN" connection.autoconnect no
      
      nmcli connection import type wireguard file /home/bobmuit/nixos-config/hosts/nixos-dell/wg-conf/SB42.conf
      nmcli connection modify "SB42" connection.autoconnect no
      
      # Also set VPN connections as non-primary
      nmcli connection modify "ProtonVPN" connection.secondaries ""
      nmcli connection modify "SB42" connection.secondaries ""

      # Set lower connection priority (higher number = lower priority)
      nmcli connection modify "ProtonVPN" connection.autoconnect-priority 10
      nmcli connection modify "SB42" connection.autoconnect-priority 10
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };


  # Enable WireGuard
  # networking.wireguard.enable = true; 