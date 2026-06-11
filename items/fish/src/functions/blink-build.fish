function blink-build --description "Rebuild blink.cmp native fuzzy matcher without Neovim"
    if not command -q cargo
        echo "blink-build: cargo not found" >&2
        return 127
    end

    if not command -q git
        echo "blink-build: git not found" >&2
        return 127
    end

    set -l data_home "$HOME/.local/share"
    if set -q XDG_DATA_HOME
        set data_home "$XDG_DATA_HOME"
    end

    set -l repo "$data_home/nvim/lazy/blink.cmp"
    if test (count $argv) -ge 1
        set repo "$argv[1]"
    end

    if not test -d "$repo/.git"
        echo "blink-build: blink.cmp repo not found at $repo" >&2
        return 1
    end

    set -l ext
    switch (uname -s)
        case Linux
            set ext so
        case Darwin
            set ext dylib
        case '*'
            echo "blink-build: unsupported platform "(uname -s) >&2
            return 1
    end

    pushd "$repo" >/dev/null

    cargo build --release
    or begin
        set -l build_status $status
        popd >/dev/null
        return $build_status
    end

    set -l commit (git rev-parse HEAD | string sub -l 7)
    set -l artifact "target/release/libblink_cmp_fuzzy.$ext"
    if not test -f "$artifact"
        set artifact "target/release/blink_cmp_fuzzy.$ext"
    end

    if not test -f "$artifact"
        echo "blink-build: built artifact not found" >&2
        popd >/dev/null
        return 1
    end

    mkdir -p lib
    or begin
        set -l mkdir_status $status
        popd >/dev/null
        return $mkdir_status
    end

    cp -f "$artifact" "lib/libblink_cmp_fuzzy.$ext.$commit"
    or begin
        set -l copy_status $status
        popd >/dev/null
        return $copy_status
    end

    set -l installed "$repo/lib/libblink_cmp_fuzzy.$ext.$commit"
    popd >/dev/null

    echo "blink.cmp native library installed: $installed"
end
