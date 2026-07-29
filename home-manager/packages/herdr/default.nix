{ config, pkgs, lib, ... }:

{
  home.file.".config/herdr/config.toml" = {
    source = ./config.toml;
  };

  home.packages = with pkgs; [
    herdr
  ];
}
