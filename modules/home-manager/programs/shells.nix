{
  pkgs,
  config,
  inputs,
  #username,
  ...
}: {

  # Bash settings
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # Configure just for bash
    initExtra = ''
      eval "$(just --completions bash)"
      alias j=just 
      alias ls="eza"
      alias ll="eza --long --all --git"
    '';

    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };

  # Install Fish shell
  programs.fish = {
    enable = true;
    shellInit = ''
      starship init fish | source
    '';
  };
  
  # Optionally, set Fish as the default shell
  # users.users.my_user.shell = pkgs.fish;

  # Optionally, install Fish plugins
  programs.fish.pluginManager.enable = true;

  programs.fish.pluginManager.plugins = [
    pkgs.fishPlugins.fzf
    pkgs.fishPlugins.z
  ];

}