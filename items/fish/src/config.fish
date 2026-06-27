set -g fish_greeting

if status is-interactive
    command -q starship; and starship init fish | source
end

fish_add_path --path $HOME/bin


zoxide init fish | source
