#!/bin/bash

# Common variables and helper functions for Zammad YunoHost scripts.

# Run a Zammad Rails runner command as the zammad system user
zammad_rails() {
    sudo -u zammad bash -c "cd /opt/zammad && RAILS_ENV=production bundle exec rails runner \"$1\""
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
