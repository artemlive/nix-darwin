{
  pkgs,
  ...
}: {
  home.file.".config/nvim" = {
    source = ./config;
    recursive = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
  };
}
