{ config, lib, pkgs, ... }:

let
  version = "2.1.317";
  
  # Map Nix system to Claude's naming convention
  platformMap = {
    "x86_64-darwin" = "darwin-x64";
    "aarch64-darwin" = "darwin-arm64";
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
  };
  
  platform = platformMap.${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
  
  # SHA256 hashes for each platform from manifest.json
  hashes = {
    "darwin-x64" = "sha256-AccUvH/r2wCPKOP2+ssdw35GpNj6jbWN8uKB7lHLMzw=";
    "darwin-arm64" = "sha256-CfFTtGtd+eizRUcW1oKpGQHeAgy8pjD2HewaAVsytek=";
    "linux-x64" = "sha256-6yJEGeNEV1+qSh85spC2SUJaEM1e4u8dADSAzZrlfrA=";
    "linux-arm64" = "sha256-VjoNYK0MIj2UFXaCEJl6yw9xNOpR3Dwjjoi8Lhjd7vo=";
  };
  
  claude-cli = pkgs.stdenv.mkDerivation {
    pname = "claude-cli";
    inherit version;
    
    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/${platform}/claude";
      sha256 = hashes.${platform};
    };
    
    dontUnpack = true;
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/claude
      chmod +x $out/bin/claude
    '';
    
    meta = with lib; {
      description = "Claude Code CLI";
      homepage = "https://code.claude.com";
      platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    };
  };
in
{
  home.packages = [ claude-cli ];
}
