{ config, pkgs, inputs, ... }:

{
  imports = [
    ./zsh
    ./nvim
    ./alacritty
    ./tmux
    ./ff
    ./fonts
    ./tools
  ];

  home.packages = with pkgs; [
    gnupg
    _1password-cli
    direnv
    cachix
    fzf
    gh
    go
    golangci-lint
    golangci-lint-langserver
    nodejs
    google-cloud-sdk
    autoconf
    autoconf-archive
    automake
    ccache
    cmake
    libtool
    nasm
    ninja
    pkg-config
    virtualenv
    bash
    cursor-cli
    inputs.devenv.packages."${pkgs.system}".devenv
  ];

  home.stateVersion = "25.11"; 

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };

  programs.home-manager.enable = true;
}
