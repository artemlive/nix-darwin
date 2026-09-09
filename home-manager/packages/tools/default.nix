{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    brotli
    c-ares
    coreutils
    direnv
    fluxcd
    fontconfig
    freetype
    fzf
    gettext
    git
    git-lfs
    gmp
    gnupg
    gnutls
    kubernetes-helm
    icu
    iproute2mac
    jansson
    jq
    k9s
    ko
    krb5
    kubectx
    kubectl
    kustomize
    lazygit
    lua
    lz4
    mongodb-tools
    mpdecimal
    msgpack-c
    mtr
    ncurses
    nettle
    nmap
    nodejs
    # OrbStack also ships kubectl + completions; drop them so they do not
    # collide with pkgs.kubectl.
    (orbstack.overrideAttrs (_: {
      postInstall = ''
        installShellCompletion --bash "$out"/Applications/OrbStack.app/Contents/Resources/completions/bash/{docker,orbctl}.bash
        installShellCompletion --zsh "$out"/Applications/OrbStack.app/Contents/Resources/completions/zsh/{_docker,_orb,_orbctl}
        installShellCompletion --fish "$out"/Applications/OrbStack.app/Contents/Resources/completions/fish/{docker,orbctl}.fish
        rm -f $out/bin/kubectl
      '';
    }))
    npth
    oniguruma
    openssl
    p11-kit
    pcre2
    pinentry_mac
    pkg-config
    popt
    pwgen
    python3
    readline
    ripgrep
    rpm
    sqlite
    stern
    tree-sitter
    unbound
    unibilium
    utf8proc
    vault
    vegeta
    wget
    xclip
    xz
    yarn
    zed-editor
  ];
}
