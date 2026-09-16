{ lib, config, ... }:

let
  cfg = config.custom.mcp;
in
{
  options.custom.mcp.servers = lib.mkOption {
    type = lib.types.attrsOf lib.types.attrs;
    default = { };
    description = "Merged into ~/.config/mcp/mcp.json for pi-mcp-adapter.";
  };

  config = {
    custom.mcp.servers.atlassian = {
      url = "https://mcp.atlassian.com/v2/mcp";
      auth = "oauth";
    };

    home.file.".config/mcp/mcp.json" = lib.mkIf (cfg.servers != { }) {
      text = builtins.toJSON { mcpServers = cfg.servers; };
    };
  };
}
