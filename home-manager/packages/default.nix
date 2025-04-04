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
    inputs.devenv.packages."${pkgs.system}".devenv
  ];

  home.stateVersion = "24.11"; 

  home.sessionVariables = {
    EDITOR = "nvim";
    DIRENV_LOG_FORMAT = "";
  };

  programs.home-manager.enable = true;
}
