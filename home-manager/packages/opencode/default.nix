{ config, lib, pkgs, ... }:
{
  xdg.configFile."opencode/opencode.json".source = ./opencode.json;
}
