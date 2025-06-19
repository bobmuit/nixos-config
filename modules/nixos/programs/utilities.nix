{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

    # Basic utilities
    git        # Distributed version control system  
    lazygit    # Terminal-based Git UI for easy navigation  
    bat         # `cat` clone with syntax highlighting, Git integration, and paging
    delta      # Enhanced `git diff` viewer with syntax highlighting  
    bottom     # Modern, fast system monitor (alternative to htop)  
    just       # Handy command runner, a modern alternative to Makefiles  
    procs      # Better `ps` alternative with readable output  
    zoxide      # Smarter `cd` command with auto-jumping  
    eza       # Modern replacement for `ls` with colors, icons, and Git support  
    fzf        # Fuzzy finder for command history, files, and more  
    ripgrep    # Fast alternative to `grep` for searching files  
    tldr        # Simplified man pages with practical examples  
    ncdu          # Disk usage analyzer with a user-friendly interface  
    yazi        # Blazing fast terminal file manager with vim-like keybindings  
    zellij      # Modern terminal workspace with built-in multiplexing and layout support  
    helix       # Fast, modal text editor inspired by Kakoune and built with Rust  

    # Networking
    dnsutils  # Collection of command-line tools for DNS queries, including dig, nslookup, and host

    # Nix utilities
    comma      # Nix utility that lets you run any package temporarily by prefixing its name with a comma

  ];

  # Set default editor to Helix
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

}