{ config, lib, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "0xProto Nerd Font";
      size = 13;
    };
    
    # Catppuccin Mocha theme
    theme = "Catppuccin-Mocha";
    
    settings = {
      # Window
      background_opacity = "0.9";
      window_padding_width = 10;
      hide_window_decorations = "titlebar-only";
      macos_titlebar_color = "background";
      
      # Shell
      shell = "/bin/zsh";
      shell_integration = "enabled";
      
      # Tab bar
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # macOS specific
      macos_option_as_alt = "both";
      macos_quit_when_last_window_closed = "no";
      
      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 0;
      
      # Scrollback
      scrollback_lines = 10000;
      
      # Mouse
      copy_on_select = "yes";
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      
      # Advanced
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      
      # Graphics
      kitty_graphics_protocol = "enabled";
    };
    
    keybindings = {
      # Tab management
      "cmd+t" = "new_tab";
      "cmd+w" = "close_tab";
      "cmd+]" = "next_tab";
      "cmd+[" = "previous_tab";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      
      # Window management
      "cmd+n" = "new_os_window";
      "cmd+shift+n" = "new_window";
      
      # Font size
      "cmd+equal" = "change_font_size all +2.0";
      "cmd+minus" = "change_font_size all -2.0";
      "cmd+0" = "change_font_size all 0";
      
      # Miscellaneous
      "cmd+c" = "copy_to_clipboard";
      "cmd+v" = "paste_from_clipboard";
    };
  };
}
