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

      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
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
    plugins = [
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf.src;
      }
    ];
    # Use the built-in zoxide integration instead of as a plugin
    interactiveShellInit = ''
      zoxide init fish | source
    '';
  };
  
  programs.starship.enable = true;

  # Make sure zoxide is installed
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

}