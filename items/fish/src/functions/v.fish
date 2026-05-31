function v --description "Open nvim in the current terminal"
    if not command -q nvim
        echo "v: nvim not found" >&2
        return 127
    end

    command nvim $argv
end
