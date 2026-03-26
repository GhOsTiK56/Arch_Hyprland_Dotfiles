if status is-interactive
# Commands to run in interactive sessions can go here
	fastfetch
  alias ls='lsd'
  alias l='ls -l'
  alias la='ls -a'
  alias lla='ls -la'
  alias lt='ls --tree'
  alias cat='bat'
  zoxide init fish | source
end

set fish_greeting

# Flutter
set -gx PATH /home/ghostik/Android/flutter/bin $PATH

# npm-global
set -gx PATH ~/.npm-global/bin $PATH

