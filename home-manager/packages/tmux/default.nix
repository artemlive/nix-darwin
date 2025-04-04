{ config, pkgs, lib, ... }: {
  programs.tmux = {
    enable = true;
    historyLimit = 1000000;
    terminal = "screen-256color";
    extraConfig = lib.strings.fileContents ./tmux.conf;
  };
}
