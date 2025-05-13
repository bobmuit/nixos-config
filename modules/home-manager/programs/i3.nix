{ config, pkgs, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      terminal = "alacritty";
      modifier = "Mod4"; # Super key
      keybindings = {
        "Mod4+Return" = "exec alacritty";
        "Mod4+d" = "exec rofi -show drun";
        "Mod4+Shift+e" = "exec --no-startup-id i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'";
      };
      bars = [{
        statusCommand = "i3status";
      }];
      startup = [
        { command = "nm-applet"; }
        { command = "blueman-applet"; }
        { command = "picom --config ~/.config/picom/picom.conf &"; }
        { command = "feh --bg-scale ~/Pictures/wallpapers/default.jpg"; }
        { command = "xss-lock -- i3lock --color=000000"; }
        { command = "dunst"; }
      ];
    };
  };

  services.picom.enable = true;

  home.packages = with pkgs; [
    rofi dunst feh alacritty 
  ];
}
