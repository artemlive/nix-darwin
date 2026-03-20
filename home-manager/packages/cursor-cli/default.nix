{ config, lib, pkgs, ... }:

let
  version = "2026.03.18-f6873f7";
  
  # Map Nix system to Cursor's naming
  platformMap = {
    "x86_64-darwin" = { os = "darwin"; arch = "x64"; };
    "aarch64-darwin" = { os = "darwin"; arch = "arm64"; };
    "x86_64-linux" = { os = "linux"; arch = "x64"; };
    "aarch64-linux" = { os = "linux"; arch = "arm64"; };
  };
  
  platform = platformMap.${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
  
  cursor-cli = pkgs.stdenv.mkDerivation {
    pname = "cursor-cli";
    inherit version;
    
    src = pkgs.fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/${platform.os}/${platform.arch}/agent-cli-package.tar.gz";
      sha256 = "sha256-KHybHgQrIOBHbiJZSEbFVG0Fp1+TRPvK75JXPcSTMKk=";
    };
    
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/
      
      # Create symlinks
      ln -s $out/cursor-agent $out/bin/cursor-agent
      ln -s $out/cursor-agent $out/bin/agent
      
      chmod +x $out/bin/cursor-agent
    '';
    
    meta = with lib; {
      description = "Cursor Agent CLI";
      homepage = "https://cursor.com/cli";
      platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    };
  };
in
{
  home.packages = [ cursor-cli ];
}
