{ config, ... }:

{
  imports = [ ../packages/mcp-grafana ];

  custom.mcp.servers.grafana = {
    command = "${config.home.homeDirectory}/.npm-global/bin/mcp-grafana";
    env = {
      GRAFANA_URL = "!op read --account macpaw.1password.com 'op://Employee/grafana/url'";
      GRAFANA_SERVICE_ACCOUNT_TOKEN = "!op read --account macpaw.1password.com 'op://Employee/grafana/password'";
    };
  };
}
