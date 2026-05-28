function nv --description "Open nvim in Ghostty with an editor-only profile"
    if not command -q ghostty
        echo "nv: ghostty not found" >&2
        return 127
    end

    if not command -q nvim
        echo "nv: nvim not found" >&2
        return 127
    end

    set -l profile "$HOME/.config/ghostty/nvim.ghostty"

    command ghostty \
        --config-file="$profile" \
        --working-directory="$PWD" \
        -e nvim $argv >/dev/null 2>&1 &
    set -l ghostty_pid $last_pid
    disown $ghostty_pid
end
