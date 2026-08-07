function noctalia-update --description "Update the Noctalia package and restart the user service"
    set -l package noctalia-git
    if set -q NOCTALIA_PACKAGE
        set package $NOCTALIA_PACKAGE
    end

    if command -q paru
        paru -Syu --needed --noconfirm $package
    else if command -q yay
        yay -Syu --needed --noconfirm $package
    else if command -q pacman
        sudo pacman -Syu --needed --noconfirm $package
    else
        echo "noctalia-update: no supported package manager found" >&2
        return 1
    end

    if test $status -ne 0
        return $status
    end

    systemctl --user daemon-reload
    systemctl --user restart noctalia.service
end
