{ config, lib, pkgs, ... }:

let
  version = "2.1.80";
  
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
    "darwin-x64" = "sha256-w01f2fSZLDI/Ao2FcOYtbRdLmHcSrIyLCSpkGoS+4qw=";
    "darwin-arm64" = "sha256-28JdOPDaKHCf4i8kiwj4DnPy5DFw2+3v9HvYuX245zc=";
    "linux-x64" = "sha256-Sfo896qrnVQGboXqoRkRt9JcYpqCrzI6drItsgKdT6I=";
    "linux-arm64" = "sha256-gol9Xs1VpGakcWGyG0FwdegUnKgWABuhV5b/BTca/dU=";
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
