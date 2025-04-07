{ config, lib, pkgs, ... }:
{
    programs.alacritty = {
      enable = true;
      settings = {
        general = {
          import = [
            pkgs.alacritty-theme.rose_pine
        ]; 
        };
        env = {
          TERM = "xterm-256color";
        };
  
        window = {
          opacity = 0.9;
          decorations = "full";
          decorations_theme_variant = "Dark";
          padding = {
            x = 10;
            y = 10;
          };
          option_as_alt = "Both";
        };
        terminal = { 
          shell = {
            program = "/bin/zsh";
            args = [ "-l" ];
          };
        }; 
        font = {
          normal = {
            family = "0xProto Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "0xProto Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "0xProto Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "0xProto Nerd Font";
            style = "Bold Italic";
          };
        };
       };
     };
}
