{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.pi.homeModules.default ];

  programs.pi.coding-agent = {
    enable = true;
    
    # Anthropic integration
    extraArgs = [ 
      "--provider" "anthropic"
      "--model" "claude-sonnet-4"  # or claude-opus-4, claude-haiku-4
    ];
    
    # Set Anthropic API key
    # Option 1: Set directly (not recommended for security)
    # environment.ANTHROPIC_API_KEY.value = "your-api-key-here";
    
    # Option 2: Load from file (recommended)
    # environment.ANTHROPIC_API_KEY.file = /path/to/api-key-file;
    
    # Option 3: Load from existing env var
    # The API key can also be set in your shell environment
    
    # Optional: Add custom rules
    # rules = ''
    #   Be concise and direct.
    #   Use TypeScript for new code.
    # '';
    
    # Optional: Add skills directory
    # skills = [ ./skills ];
    
    # Optional: Configure default settings
    # settings = {
    #   provider = "anthropic";
    #   model = "claude-sonnet-4";
    # };
  };
}
