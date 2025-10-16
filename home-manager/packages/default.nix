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
    inputs.devenv.packages."${pkgs.system}".devenv
  ];

  home.stateVersion = "25.11"; 

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };

  programs.home-manager.enable = true;
}
