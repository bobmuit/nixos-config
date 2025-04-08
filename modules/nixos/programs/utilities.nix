{ config, pkgs, ... }:

{

  # Starship shell prompt
  programs.starship.enable = true;

  environment.systemPackages = with pkgs; [

    # Basic utilities
    vim     # Modern, extensible Vim-based text editor  
    git        # Distributed version control system  
    lazygit    # Terminal-based Git UI for easy navigation  
    delta      # Enhanced `git diff` viewer with syntax highlighting  
    bottom     # Modern, fast system monitor (alternative to htop)  
    just       # Handy command runner, a modern alternative to Makefiles  
    procs      # Better `ps` alternative with readable output  
    zoxide      # Smarter `cd` command with auto-jumping  
    eza       # Modern replacement for `ls` with colors, icons, and Git support  
    fzf        # Fuzzy finder for command history, files, and more  
    ripgrep    # Fast alternative to `grep` for searching files  
    tldr        # Simplified man pages with practical examples  
    tmux         # Terminal multiplexer for managing multiple terminal sessions  
    ncdu          # Disk usage analyzer with a user-friendly interface  
    wget
    at

    # Networking
    dnsutils  # Collection of command-line tools for DNS queries, including dig, nslookup, and host.

  ];

  # Enable at service
  services.atd.enable = true;

}