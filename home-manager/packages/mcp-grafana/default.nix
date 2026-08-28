{ config, pkgs, lib, ... }:

{
  # Install mcp-grafana globally via npm
  home.activation.installMcpGrafana = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${config.home.homeDirectory}/.npm-global/bin:$PATH"
    export NPM_CONFIG_PREFIX="${config.home.homeDirectory}/.npm-global"
    
    # Check if mcp-grafana is already installed
    if ! command -v mcp-grafana &> /dev/null; then
      $DRY_RUN_CMD ${pkgs.nodejs}/bin/npm install -g @leval/mcp-grafana
    fi
  '';

  # Set up environment variables for Grafana MCP
  home.sessionVariables = {
    # Uncomment and configure these for your Grafana instance:
    # GRAFANA_URL = "http://localhost:3000";
    # GRAFANA_SERVICE_ACCOUNT_TOKEN = "your-token-here";
  };

  # Optional: Create a wrapper script for easy access
  home.file.".local/bin/mcp-grafana".text = ''
    #!/usr/bin/env bash
    exec ${config.home.homeDirectory}/.npm-global/bin/mcp-grafana "$@"
  '';
  
  home.file.".local/bin/mcp-grafana".executable = true;
}
