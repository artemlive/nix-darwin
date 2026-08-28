{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    darwin.url = "github:lnl7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    devenv.url = "github:cachix/devenv/v2.1.2";
    unstable.url = "github:NixOS/nixpkgs/master";
    pi.url = "github:lukasl-dev/pi.nix";
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
    let
      system = "aarch64-darwin";

      commonSettings = { user, homePath }:
        ({ pkgs, config, inputs, ... }: {
          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            inputs.alacritty-theme.overlays.default
            inputs.nixpkgs-firefox-darwin.overlay
          
            (final: prev:
              let
                unstablePkgs = import inputs.unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              in {
                opencode = unstablePkgs.opencode;
                zed-editor = unstablePkgs.zed-editor;
                herdr = unstablePkgs.herdr;
              })
          ];

          users.users.${user} = {
            name = user;
            home = homePath;
          };
          system.primaryUser = user;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import home-manager/packages;


          system.stateVersion = 6;
  	  ids.gids.nixbld = 350;

          services = {
            skhd = {
              enable = true;
              skhdConfig = builtins.readFile ./home-manager/packages/skhd/skhdrc;
            };
            yabai = {
              enable = true;
              extraConfig = builtins.readFile ./home-manager/packages/yabai/yabairc;
            };
          };

          environment.systemPackages = [
            darwin.packages.${system}.darwin-rebuild
          ];

          environment.variables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
            PATH = "${config.environment.systemPath}:/run/current-system/sw/bin";
          };

          programs.zsh.enable = true;

          nix.settings = {
            trusted-users = [ "root" user ];
            build-users-group = "nixbld";
            extra-substituters = [ 
              "https://devenv.cachix.org"
              "https://pi.cachix.org"
              "https://nix-community.cachix.org"
            ];
            extra-trusted-public-keys = [
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
              "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
            experimental-features = [ "nix-command" "flakes" ];
          };
        });
    in {
      darwinConfigurations."kid-NVC2WY0X0J-MBP" = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.backupFileExtension = "backup";
          }
          (commonSettings {
            user = "artemlive";
            homePath = "/Users/artemlive";
          })
        ];
      };

      darwinConfigurations."quark-mac" = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.backupFileExtension = "backup";
            system.activationScripts.postActivation.text = ''
            mkdir -p /usr/local/bin
            ln -snf /Applications/Godot.app/Contents/MacOS/Godot /usr/local/bin/godot
            '';
          }
          (commonSettings {
            user = "artemlive";
            homePath = "/Users/artemlive";
          })
        ];
      };
    };
}
