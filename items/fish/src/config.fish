set -g fish_greeting

if status is-interactive
    command -q starship; and starship init fish | source
end

fish_add_path --path $HOME/bin
fish_add_path --path $HOME/.local/bin
fish_add_path "/home/x/.cache/.bun/bin"

zoxide init fish | source

# kimi-code
fish_add_path -g "/home/x/.kimi-code/bin"

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
