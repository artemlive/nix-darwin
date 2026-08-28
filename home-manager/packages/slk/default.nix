{ config, lib, pkgs, ... }:

let
  version = "0.16.0";
  
  # Map Nix system to slk's naming convention
  platformMap = {
    "x86_64-darwin" = "darwin_x86_64";
    "aarch64-darwin" = "darwin_arm64";
    "x86_64-linux" = "linux_x86_64";
    "aarch64-linux" = "linux_arm64";
  };
  
  platform = platformMap.${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
  
  # SHA256 hashes for each platform
  hashes = {
    "darwin_x86_64" = "";
    "darwin_arm64" = "sha256-DV66IUDO0KaSgaNkP3MqgNzvfRs/6pt0B1IU120h3L4=";
    "linux_x86_64" = "";
    "linux_arm64" = "";
  };
  
  slk = pkgs.stdenv.mkDerivation {
    pname = "slk";
    inherit version;
    
    src = pkgs.fetchurl {
      url = "https://github.com/gammons/slk/releases/download/v${version}/slk_${version}_${platform}.tar.gz";
      sha256 = hashes.${platform};
    };
    
    sourceRoot = ".";
    
    nativeBuildInputs = [ pkgs.makeWrapper ];
    
    installPhase = ''
      mkdir -p $out/bin
      cp slk $out/bin/slk
      chmod +x $out/bin/slk
      
      # Wrap the binary to ensure it has access to required libraries
      wrapProgram $out/bin/slk \
        --prefix PATH : ${lib.makeBinPath [ ]}
    '';
    
    meta = with lib; {
      description = "A blazingly fast Slack TUI";
      homepage = "https://getslk.sh";
      license = licenses.mit;
      platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
      mainProgram = "slk";
    };
  };
in
{
  home.packages = [ slk ];
  
  # slk configuration
  home.file.".config/slk/config.toml" = {
    text = ''
      [appearance]
      # Override image protocol to use kitty graphics
      # Options: auto, kitty, sixel, halfblock, off
      image_protocol = "kitty"
    '';
    force = true;  # Overwrite existing config
  };
}
