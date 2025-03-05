{
  pkgs,
  config,
  #username,
  ...
}: {
  programs = {
    firefox = {
      enable = true;
      #profiles.${username} = {};
      profiles.bobmuit = {};
    };
  };
}