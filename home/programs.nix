{ config, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Maxime";
    userEmail = "maxime@example.com"; # TODO: Replace with actual email
    
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "simple";
      pull.rebase = false;
      core.editor = "code --wait";
      
      # Better diffs
      diff.tool = "vscode";
      merge.tool = "vscode";
      
      # GitHub CLI integration
      credential.helper = "osxkeychain";
    };
    
    aliases = {
      st = "status -s";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate --all";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      # Better CLI tools
      ls = "eza --icons";
      ll = "eza -la --icons";
      tree = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      
      # System shortcuts
      ..= "cd ..";
      ...= "cd ../..";
      ....= "cd ../../..";
      
      # Nix shortcuts
      nix-search = "nix search nixpkgs";
      nix-shell = "nix shell";
      rebuild = "darwin-rebuild switch --flake ~/.config/nix";
      
      # Development shortcuts
      dc = "docker-compose";
      k = "kubectl";
    };
    
    initExtra = ''
      # Custom prompt (if not using oh-my-zsh)
      autoload -U colors && colors
      PS1="%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[blue]%}%~%{$reset_color%}$ "
      
      # History settings
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_REDUCE_BLANKS
      
      # Directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      
      # Load mise if available
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi
      
      # Load direnv if available
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi
    '';
  };

  # Direnv for environment management
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Starship prompt (modern prompt)
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };
      
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };
      
      nodejs = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
      };
      
      python = {
        format = "[$symbol$pyenv_prefix($version )]($style)";
        symbol = " ";
      };
      
      rust = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
      };
      
      golang = {
        format = "[$symbol($version )]($style)";
        symbol = " ";
      };
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    mouse = true;
    
    extraConfig = ''
      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \\; display-message "Config reloaded!"
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      
      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
    '';
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    
    extraConfig = ''
      Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519
    '';
  };
}