{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.pi.homeModules.default ];

  # pi.nix `models = ...` copies once and never overwrites a regular file.
  # Home Manager owns this path so each rebuild updates the catalog.
  home.file.".pi/agent/models.json" = {
    source = ./models.json;
    force = true;
  };

  programs.pi.coding-agent = {
    enable = true;

    settings = {
      defaultProvider = "ollama";
      defaultModel = "qwen3.8-pi:27b";
      enableSkillCommands = true;
      # jq merge is `existing * nix`, so this array replaces packages on each `pi` start.
      packages = [
        "npm:@0xkobold/pi-cursor"
      ];
    };

    # Set Anthropic API key
    # Option 1: Set directly (not recommended for security)
    # environment.ANTHROPIC_API_KEY.value = "your-api-key-here";

    # Option 2: Load from file (recommended)
    # environment.ANTHROPIC_API_KEY.file = /path/to/api-key-file;

    # Option 3: Load from existing env var
    # The API key can also be set in your shell environment

    rules = ''
      Prefer the smallest change that solves the asked task.
      Do not explore unrelated packages, history, or infra.
      Search only when the user did not name a file.
      If the request is ambiguous, ask one question instead of scanning the tree.
      Do not invent extra cleanup, refactors, or drive-by tests.
    '';

    # Optional: Add skills directory
    # skills = [ ./skills ];
  };
}
