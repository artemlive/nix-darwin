{ config, lib, pkgs, ... }:
{
  xdg.configFile."opencode/opencode.json".source = ./opencode.json;
  
  # Copy skills directory recursively
  xdg.configFile."opencode/skills" = {
    source = ./skills;
    recursive = true;
  };
}
