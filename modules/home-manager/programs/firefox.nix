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
      bookmarks = {
        force = true;
        settings = [
          {
            toolbar = true; # Show in bookmark toolbar
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
                name = "Home Assistant";
                url = "http://192.168.1.180:8123/";
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
                name = "Gemini";
                url = "https://gemini.google.com/app";
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
      };

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin        
        privacy-badger       
        bitwarden            
        clearurls            
        decentraleyes        
        canvasblocker        
        sponsorblock
        darkreader
        zotero-connector
        joplin-web-clipper
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

        # Set Heimdall as standard startup page        
        "browser.startup.homepage" = "http://192.168.1.180:8056/"; # Replace with your desired homepage

        # Disable WebRTC 
        "media.peerconnection.enabled" = false;
        
        # DNS over HTTPS
        # "network.trr.mode" = 2;  # 2 = TRR preferred (DoH with regular DNS as fallback)
        # "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

        # Make Firefox use standard DNS settings
        # and therefore defer to PiHole
        "network.trr.mode" = 0;  # 0 = Off (disabled)
        
        # Force Firefox to use system DNS
        "network.proxy.type" = 0;  # No proxy
        "network.proxy.socks_remote_dns" = false;
        # "network.captive-portal-service.enabled" = false;
        # "network.connectivity-service.enabled" = false;

        # Disable DNS resolver cache
        "network.dnsCacheExpiration" = 0;
        "network.dnsCacheEntries" = 0;
        # "network.dns.disableIPv6" = true;

        # Force specific DNS server (your Pi-hole)
        # "network.dns.forceResolve" = "192.168.1.3";  # Adjust to your Pi-hole IP

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
        default = "ddg";
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

          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/?query={searchTerms}";
            }];
            icon = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@hm" ];
          };

          "ProtonDB" = {
            urls = [{
              template = "https://www.protondb.com/search?q={searchTerms}";
            }];
            icon = "https://www.protondb.com/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@proton" ];
          };
          "ddg".metaData.hidden = false;
          "google".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "Twitter".metaData.hidden = true;
          "Wikipedia".metaData.hidden = false;
        };
      };
    };
  };
}