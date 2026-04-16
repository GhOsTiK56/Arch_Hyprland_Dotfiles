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

set -gx EDITOR nvim
set -gx VISUAL nvim

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end


set fish_greeting

# Flutter
set -gx PATH /home/ghostik/Documents/Android/flutter/bin $PATH
set -gx PATH /home/ghostik/Documents/Android/Sdk $PATH

# npm-global
set -gx PATH ~/.npm-global/bin $PATH

