if status is-interactive
    fastfetch
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
    alias cat='bat'
    zoxide init fish | source
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set fish_greeting

set -gx PATH $HOME/.npm-global/bin $PATH

set -gx ANDROID_HOME /home/ghostik/Documents/Android/Sdk/
set -gx ANDROID_SDK_ROOT $ANDROID_HOME

set -gx PATH /home/ghostik/Documents/Android/flutter/bin $PATH
set -gx PATH /home/ghostik/Documents/Android/Sdk $PATH

set -gx PATH $ANDROID_HOME/cmdline-tools/latest/bin/ $PATH
set -gx PATH $ANDROID_HOME/platform-tools/ $PATH
set -gx PATH $ANDROID_HOME/emulator/ $PATH
