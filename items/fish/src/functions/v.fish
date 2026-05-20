function v --description "Open Neovide in the current directory or with paths"
    if not command -q neovide
        echo "v: neovide not found" >&2
        return 127
    end

    if test (count $argv) -eq 0
        command neovide --fork --chdir "$PWD"
    else
        command neovide --fork $argv
    end
end
