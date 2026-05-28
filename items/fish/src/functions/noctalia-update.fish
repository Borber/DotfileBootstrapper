function noctalia-update --description "Update local Noctalia config and restart the user service"
    set -l repo "$HOME/git/DotfileBootstrapper"
    set -l bootstrap "$repo/bootstrap"

    if not test -x "$bootstrap"
        echo "noctalia-update: $bootstrap not found or not executable" >&2
        return 1
    end

    pushd "$repo" >/dev/null
    ./bootstrap install --item=noctalia-local -c -D -v
    set -l bootstrap_status $status
    popd >/dev/null

    if test $bootstrap_status -ne 0
        return $bootstrap_status
    end

    systemctl --user restart noctalia.service
end
