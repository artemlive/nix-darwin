{ config, lib, pkgs, ... }:
{
  xdg.configFile."opencode/opencode.json".source = ./opencode.json;
  
  # Copy skills directory recursively (read-only is fine for skills)
  xdg.configFile."opencode/skills" = {
    source = ./skills;
    recursive = true;
  };
  
  # Use activation script to copy package.json and plugins as actual files with proper ownership
  home.activation.opencodePlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    OPENCODE_DIR="$HOME/.config/opencode"
    PLUGINS_SRC="${./plugins}"
    PACKAGE_JSON_SRC="${./package.json}"
    
    # Ensure directories exist
    mkdir -p "$OPENCODE_DIR/plugins"
    
    # Copy package.json as regular file
    if [ -f "$PACKAGE_JSON_SRC" ]; then
      cp -f "$PACKAGE_JSON_SRC" "$OPENCODE_DIR/package.json"
      chmod 644 "$OPENCODE_DIR/package.json"
    fi
    
    # Copy plugin files as regular files
    if [ -d "$PLUGINS_SRC" ]; then
      cp -f "$PLUGINS_SRC"/*.ts "$OPENCODE_DIR/plugins/" 2>/dev/null || true
      chmod 644 "$OPENCODE_DIR/plugins"/*.ts 2>/dev/null || true
    fi
  '';
}
