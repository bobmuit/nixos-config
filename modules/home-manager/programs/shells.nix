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

       # Set up aliases
      alias j=just
      alias ls="eza"
      alias ll="eza --long --all --git"
      alias lg="lazygit"

      # Just completions in Fish
      just --completions fish | source
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
  
  # Starship configuration
  programs.starship = {
    enable = true;
    settings = {
      format = "$hostname in $directory$git_branch$git_status\n$character";
      command_timeout = 10000;
      
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style)";
        style = "red";
      };
      
      directory = {
        format = "[$path]($style)";
        style = "blue";
        truncation_length = 1;
        truncate_to_repo = true;
      };
      
      git_branch = {
        format = " on [$symbol$branch]($style)";
      };
      
      git_status = {
        format = "[ $all_status$ahead_behind ]($style)";
        style = "red";
      };
      
      character = {
        success_symbol = "[❯](green) ";
        error_symbol = "[❯](red) ";     # Keep red for errors, or change to green too
        vicmd_symbol = "[❮](green) ";
      };
    };
  };

  # Make sure zoxide is installed
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

}
