{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    darwin.url = "github:lnl7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    devenv.url = "github:cachix/devenv/latest";
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
          ];
          users.users.${user} = {
            name = user;
            home = homePath;
          };

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = import home-manager/packages;
          system.stateVersion = 6;
          ids.gids.nixbld = 30000;
          
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
          environment = {
            variables = {
              EDITOR = "nvim";
              VISUAL = "nvim";
              PATH = "${config.environment.systemPath}:/run/current-system/sw/bin";
            };
          };
          programs.zsh.enable = true;
          nix.settings = {
            trusted-users = [ "root" user ];
            build-users-group = "nixbld";
            extra-substituters = [ "https://devenv.cachix.org" ];
            extra-trusted-public-keys = [
              "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            ];
            experimental-features = [ "nix-command" "flakes" ];
          };
        });
    in {
      darwinConfigurations."urva-NVC2WY0X0J-MBP" = darwin.lib.darwinSystem {
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
          }
          (commonSettings {
            user = "artemlive1";
            homePath = "/Users/artemlive1";
          })
        ];
      };

      darwinConfigurations."personal-mac" = darwin.lib.darwinSystem {
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
          }
          (commonSettings {
            user = "artemlive";
            homePath = "/Users/artemlive";
          })
        ];
      };
    };
}
