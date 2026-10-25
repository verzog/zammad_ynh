#!/bin/bash

# Common variables and helper functions for Zammad YunoHost scripts.

# Run a Ruby snippet through Zammad's own Rails runner, as the zammad user.
#
# We use `zammad run rails runner`, the official Zammad CLI wrapper that sets up
# the correct Ruby + Bundler environment (GEM_HOME, BUNDLE_PATH, etc.) exactly
# as the running service does. Calling the vendored ruby/bundler directly
# bypasses that environment and breaks on git-sourced gems (e.g. delayed_job)
# whose checkout path only exists under the configured BUNDLE_PATH.
#
# The snippet is written to a private temp file (0600, owned by zammad) rather
# than passed on the command line, so the arguments — which may contain secrets
# such as the generated admin password — never appear in `ps` output or in a
# world-readable file.
zammad_rails() {
    local tmpfile rc=0
    # Restrict the temp file to its owner before anything is written to it.
    tmpfile=$(umask 077 && mktemp /tmp/zammad_rails_XXXXXX.rb)
    printf '%s\n' "$1" > "$tmpfile"
    # The runner reads the file as the zammad user, so grant it read access
    # without widening to the rest of the system.
    chown zammad:zammad "$tmpfile" 2>/dev/null || chmod 644 "$tmpfile"
    sudo -u zammad bash -c "zammad run rails runner '${tmpfile}'" || rc=$?
    rm -f "$tmpfile"
    return $rc
}

# Wait for Zammad's web server to become available on $port
# Usage: wait_for_zammad [timeout_seconds]
wait_for_zammad() {
    local timeout="${1:-120}"
    local elapsed=0

    while ! curl -sf -o /dev/null "http://127.0.0.1:$port/"; do
        sleep 3
        elapsed=$((elapsed + 3))
        if [ "$elapsed" -ge "$timeout" ]; then
            ynh_die "Zammad did not respond within ${timeout}s. Check: journalctl -u zammad-web -n 50"
        fi
    done
}
