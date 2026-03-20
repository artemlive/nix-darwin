{ config, lib, pkgs, ... }:

let
  version = "4.1.3";
  
  # Map Nix system to Helm's naming convention
  platformMap = {
    "x86_64-darwin" = { os = "darwin"; arch = "amd64"; };
    "aarch64-darwin" = { os = "darwin"; arch = "arm64"; };
    "x86_64-linux" = { os = "linux"; arch = "amd64"; };
    "aarch64-linux" = { os = "linux"; arch = "arm64"; };
  };
  
  platform = platformMap.${pkgs.system} or (throw "Unsupported system: ${pkgs.system}");
  
  # SHA256 hashes for each platform from get.helm.sh
  hashes = {
    "darwin-amd64" = "sha256-dCEy4RzAioHJf3AYDNcUroN2+MiWJHp7FK4fUYOLWgs=";
    "darwin-arm64" = "sha256-IcAv4vfifQjiSmv5MQP50rJaq28T+RgUss+ryZsQil4=";
    "linux-amd64" = "sha256-As6XItVBI4+BRZk4uEz0ffL98Rh0k7S/sjRnVNgqRwA=";
    "linux-arm64" = "sha256-XbReAnzI3kZ37IaeXYA/x2MbC6scHrYqxgOmLSI1mkM=";
  };
  
  platformKey = "${platform.os}-${platform.arch}";
  
  helm4 = pkgs.stdenv.mkDerivation {
    pname = "helm4";
    inherit version;
    
    src = pkgs.fetchurl {
      url = "https://get.helm.sh/helm-v${version}-${platformKey}.tar.gz";
      sha256 = hashes.${platformKey};
    };
    
    nativeBuildInputs = [ pkgs.makeWrapper ];
    
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/bin
      # Nix automatically unpacks and cd's into the extracted directory
      # So we can directly copy the helm binary
      cp helm $out/bin/helm4
      chmod +x $out/bin/helm4
    '';
    
    meta = with lib; {
      description = "Helm 4 - The Kubernetes Package Manager";
      homepage = "https://helm.sh";
      license = licenses.asl20;
      platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
    };
  };
in
{
  home.packages = [ helm4 ];
}
