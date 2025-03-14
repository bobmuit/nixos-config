{
  pkgs,
  config,
  inputs,
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
              url = "http://192.168.1.180:8056/";
            }
            {
              name = "FreshRSS";
              url = "http://192.168.1.180:8057/";
            }
            {
              name = "Paperless";
              url = "http://192.168.1.180:8777/";
            }
            {
              name = "Calibre";
              url = "http://192.168.1.180:8083/";
            }
            {
              name = "Perplexity";
              url = "https://www.perplexity.ai/";
            }
            {
              name = "Claude";
              url = "https://claude.ai/";
            }
            {
              name = "ChatGPT";
              url = "https://chatgpt.com/";
            }
            {
              name = "GitHub";
              url = "https://github.com/";
            }
            {
              name = "NixOS Discourse";
              url = "https://discourse.nixos.org/";
            }
          ];
        }
      ];

      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin         # uBlock Origin
        privacy-badger        # Privacy Badger
        bitwarden            # Bitwarden
        clearurls            # ClearURLs
        decentraleyes        # Decentraleyes
        canvasblocker        # Canvas Blocker
        # cookie-autodelete    # Cookie AutoDelete
        sponsorblock
        darkreader
        zotero-connector
      ];
      
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
        "privacy.firstparty.isolate" = false;
        
        # Enhanced tracking protection
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        
        # Resist fingerprinting
        "privacy.resistFingerprinting" = false;
        
        # Disable pocket
        "extensions.pocket.enabled" = false;
        
        # HTTPS-Only mode
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        
        # Disable location tracking
        "geo.enabled" = false;
        
        # Clear history and cookies on exit
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "privacy.clearOnShutdown.history" = true;
        "privacy.clearOnShutdown.cookies" = false; # Keep cookings
        "privacy.clearOnShutdown.cache" = true;
        "privacy.clearOnShutdown.downloads" = true;
        "privacy.clearOnShutdown.formdata" = true;
        "privacy.clearOnShutdown.sessions" = false; # Keep sessions
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = false;  # Keep site settings
        
        # Enable persistent storage for logins
        "browser.sessionstore.enabled" = true;
        "browser.sessionstore.privacy_level" = 0;  # Store all session data
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.resume_session_once" = true;

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

        # Store login information
        "signon.rememberSignons" = true;
        "browser.privatebrowsing.autostart" = false;

        # Cookie settings
        "network.cookie.lifetimePolicy" = 0; # Accept cookies normally
        "network.cookie.cookieBehavior" = 1; # Only accept from the originating site
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