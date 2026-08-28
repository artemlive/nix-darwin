{ config, pkgs, inputs, ... }:

{
  imports = [
    ./zsh
    ./nvim
    ./alacritty
    ./kitty
    ./tmux
    ./ff
    ./fonts
    ./tools
    ./opencode
    ./cursor-cli
    ./claude-cli
    ./helm4
    ./herdr
    ./pi
    ./mcp-grafana
    ./slk
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
    opencode
    inputs.devenv.packages."${pkgs.system}".devenv
  ];

  home.stateVersion = "25.11"; 

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };
  
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # Create npm global directory
  home.file.".npm-global/.keep".text = "";
  
  # Configure npm to use local prefix
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  programs.home-manager.enable = true;
}
