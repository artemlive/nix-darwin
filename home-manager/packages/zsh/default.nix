{ pkgs, ... }:
{
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
  #  home.sessionPath = [
  #	  "${pkgs.neovim-unwrapped}/bin"
  #];
  programs.zsh = {
    enable = true;
    shellAliases = {
      "cat" = "bat";
      "top" = "btop";
      "grep" = "rg";
      "k" = "kubectl";
    };
    initExtra = ''
       source "$HOME/.zsh/plugins/zsh-kubectl-prompt/zsh-kubectl-prompt.plugin.zsh"
       autoload -Uz colors && colors
       RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

       start_yabai() {
          launchctl load ~/Library/LaunchAgents/org.nixos.yabai.plist
       }

       stop_yabai() {
          launchctl unload ~/Library/LaunchAgents/org.nixos.yabai.plist
       }

       restart_yabai() {
          stop_yabai
          start_yabai
       }
       flowschema_sa() {
         kubectl get po --v=8 --as system:serviceaccount:kube-system:"$1" 2>&1 | grep -i x-kubernetes-pf
       }
     
       flowschemas() {
         kubectl get flowschemas -o custom-columns="uid:{metadata.uid},name:{metadata.name}"
       }
     
       priorities() {
         kubectl get prioritylevelconfiguration -o custom-columns="uid:{metadata.uid},name:{metadata.name}"
       }
     
       dump_api() {
         kubectl get --raw "/debug/api_priority_and_fairness/dump_requests?includeRequestDetails=1"
       }
     
       dump_pr() {
         kubectl get --raw "/debug/api_priority_and_fairness/dump_priority_levels"
       }
       auth_openai() {
         if [[ -z "$OPENAI_API_KEY" ]]; then
           export OPENAI_API_KEY="$(op read op://Personal/OpenAI/password)"
           echo "OPENAI_API_KEY loaded ✅"
         else
           echo "OPENAI_API_KEY is already set 🔒"
         fi
       }
	''; 
     plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-bat";
          src = pkgs.fetchFromGitHub {
            owner = "fdellwing";
            repo = "zsh-bat";
            rev = "467337613c1c220c0d01d69b19d2892935f43e9f";
            sha256 = "sha256-TTuYZpev0xJPLgbhK5gWUeGut0h7Gi3b+e00SzFvSGo"; # adjust if needed
          };
          file = "zsh-bat.plugin.zsh";
        }
        {
          name = "zsh-kubectl-prompt";
          src = pkgs.fetchFromGitHub {
            owner = "superbrothers";
            repo = "zsh-kubectl-prompt";
            rev = "cc8e2d15b56cf0dfff0954b30bd604fe9bcfcee3"; # pick stable or latest
            sha256 = "sha256-YmQVK7nn59YJ/OV0mM+R4OI0SdB2oIS8xeZrBlSAwuw="; # adjust if needed
          };
          file = "kubectl.plugin.zsh";
        }
      ];
    "oh-my-zsh" = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
	  "git"
	  "1password"
	  "tmux"
	  "cabal"
	  "copybuffer"
	  "docker-compose"
	  "docker"
	  "direnv"
	  "dotenv"
	  "encode64"
	  "fluxcd"
	  "fzf"
	  "gcloud"
	  "gh"
	  "golang"
	  "hasura"
	  "helm"
	  "httpie"
	  "kubectl"
	  "node"
	  "npm"
	  "pip"
	  "python"
	  "redis-cli"
	  "qrcode"
	  "rust"
	  "sudo"
	  "terraform"
	  "yarn"
	  "z"
	  "kubectx"
      ];
    };
    sessionVariables = {
      ZSH_TMUX_AUTOSTART = false;
      ZSH_TMUX_AUTOCONNECT = false;
      ZSH_DOTENV_PROMPT = false;
    };
  };
}
