{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.firefox-bin ];
  home.activation.linkFirefoxChrome = lib.hm.dag.entryAfter ["writeBoundary"] ''
    PROFILE_DIR=$(find "$HOME/Library/Application Support/Firefox/Profiles" -maxdepth 1 -type d -name "*.default-release" | head -n 1)

    if [ -n "$PROFILE_DIR" ]; then
      mkdir -p "$PROFILE_DIR/chrome/tweaks"
      ln -sf "${./userChrome.css}" "$PROFILE_DIR/chrome/userChrome.css"
      ln -sf "${./tweaks/toolbars_below_content.css}" "$PROFILE_DIR/chrome/tweaks/toolbars_below_content.css"
    fi
  '';
}
