{ config, pkgs, ... }:

let
  # Define the list of desired R packages
  myRPackages = with pkgs.rPackages; [
    # Basics
    languageserver
    ggplot2
    dplyr
    tidyr

    # Meta-analysis
    meta
    netmeta

    # Markdown
    rmarkdown
    knitr
    tinytex
    # Add other R packages here as needed
  ];

  # Create a custom R environment by wrapping R with the specified packages
  customR = pkgs.rWrapper.override {
    packages = myRPackages;
  };

in
{
  # Add R and the custom R environment to systemPackages
  environment.systemPackages = with pkgs; [
    R                  # Install R
    customR            # Install the custom R environment with the specified packages

    pandoc
  ];
}
