{
  pkgs,
  config,
  #username,
  ...
}: {
  programs.firefox = {
    enable = true;
    
    # Privacy settings
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      
      # Add bookmark toolbar
      bookmarks = [
        {
          toolbar = true;         # Show in toolbar (optional)
          bookmarks = [
            {
              name = "Heimdall";
              url = "hhttp://192.168.1.180:8056/";
            }
            {
              name = "Paperless";
              url = "http://192.168.1.180:8777/";
            }
          ];
        }
      ];

      # extensions = with pkgs.firefox-addons; [
      #   ublock-origin         # uBlock Origin
      #   privacy-badger        # Privacy Badger
      #   https-everywhere      # HTTPS Everywhere (deprecated, but still available)
      #   bitwarden            # Bitwarden
      #   clearurls            # ClearURLs
      #   decentraleyes        # Decentraleyes
      #   facebook-container   # Facebook Container
      #   canvasblocker        # Canvas Blocker
      #   cookie-autodelete    # Cookie AutoDelete
      # ];
      
      settings = {
        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        
        # Disable studies
        "app.shield.optoutstudies.enabled" = false;
        "app.normandy.enabled" = false;
        "app.normandy.api_url" = "";
        
        # Disable crash reports
        "breakpad.reportURL" = "";
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        
        # Disable prefetching
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        
        # First party isolate
        "privacy.firstparty.isolate" = true;
        
        # Enhanced tracking protection
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        
        # Resist fingerprinting
        "privacy.resistFingerprinting" = true;
        
        # Disable pocket
        "extensions.pocket.enabled" = false;
        
        # HTTPS-Only mode
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        
        # Disable location tracking
        "geo.enabled" = false;
        
        # Clear history and cookies on exit
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown.history" = true;
        "privacy.clearOnShutdown.cookies" = false; # Keep cookings
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.sessions" = false; # Keep sessions
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = false;  # Keep site settings
        
        # Disable auto-filling
        "browser.formfill.enable" = false;
        
        # Use DuckDuckGo as default search engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.selectedEngine" = "DuckDuckGo";
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        
        # Disable search suggestions
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        
        # Disable WebRTC 
        "media.peerconnection.enabled" = false;
        
        # DNS over HTTPS
        "network.trr.mode" = 2;  # 2 = TRR preferred (DoH with regular DNS as fallback)
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

        # Make Firefox use standard DNS settings
        # and therefore defer to PiHole
        # Use this once figured out Wireguard
        # "network.trr.mode" = 0;  # 0 = Off (disabled)

        # Keep bookmark toolbar visible
        "browser.toolbars.bookmarks.visibility" = "always";  # Options: "always", "newtab", "never"

      };

      search = {
        force = true;
        default = "DuckDuckGo";
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Wiki" = {
            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # daily
            definedAliases = [ "@nw" ];
          };
          "DuckDuckGo".metaData.hidden = false;
          "Google".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "Bing".metaData.hidden = true;
          "eBay".metaData.hidden = true;
          "Twitter".metaData.hidden = true;
          "Wikipedia".metaData.hidden = false;
        };
      };
    };
  };
}