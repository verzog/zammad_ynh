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

# Configure (or migrate) the YunoHost LDAP integration in Zammad.
#
# Idempotent and customization-preserving, so it is safe to run from BOTH
# install and upgrade. Package-managed connection/search fields are (re)set to
# the current YunoHost values only when they are blank or still hold a previous
# package default, so an admin's manual edits (bind credentials, a custom base
# DN, extra group->role mappings) are preserved. The admins->Admin+Agent mapping
# is added when absent but never overwrites an existing entry.
#
# Schema/behaviour verified against upstream: spec/factories/ldap_source.rb,
# lib/ldap/group.rb and db/seeds/settings.rb. YunoHost group schema (admins
# group DN, groupOfNamesYnh, member DNs) from YunoHost's src/user.py.
zammad_configure_ldap() {
    zammad_rails "
Setting.set('ldap_integration', true)

admins_group   = 'cn=admins,ou=groups,dc=yunohost,dc=org'
admin_role_ids = Role.where(name: ['Admin', 'Agent']).order(:id).pluck(:id).map(&:to_s)

source = LdapSource.find_or_initialize_by(name: 'YunoHost')
prefs  = source.preferences || {}

# Previous package defaults that may be migrated forward to current values.
old_base         = 'ou=users,dc=yunohost,dc=org'
old_user_filter  = '(objectClass=posixAccount)'
old_group_filter = '(objectClass=posixGroup)'

# Connection basics: set only when unset, to preserve admin overrides.
prefs['host']             ||= 'localhost'
prefs['port']             ||= 389
prefs['ssl']              ||= 'off'
prefs['ssl_verify']         = false if prefs['ssl_verify'].nil?
prefs['options']          ||= { 'dc=yunohost,dc=org' => 'dc=yunohost,dc=org' }
prefs['option']           ||= 'dc=yunohost,dc=org'
prefs['bind_user']        ||= ''
prefs['bind_pw']          ||= ''
prefs['user_uid']         ||= 'uid'
prefs['group_uid']        ||= 'dn'
prefs['user_attributes']  ||= { 'uid' => 'login', 'mail' => 'email', 'givenname' => 'firstname', 'sn' => 'lastname' }
prefs['unassigned_users'] ||= 'sigup_roles'

# Search scope / filters: set when blank or still a prior package default, so
# the root base DN and YunoHost group objectClass needed for group mapping are
# migrated forward without clobbering a value the admin customised.
prefs['base_dn']      = 'dc=yunohost,dc=org' if prefs['base_dn'].blank? || prefs['base_dn'] == old_base
prefs['user_filter']  = '(&(objectClass=posixAccount)(!(uid=root))(!(uid=nobody)))' if prefs['user_filter'].blank? || prefs['user_filter'] == old_user_filter
prefs['group_filter'] = '(objectClass=groupOfNamesYnh)' if prefs['group_filter'].blank? || prefs['group_filter'] == old_group_filter

# Ensure the admins mapping exists without discarding admin-defined entries
# (existing keys win over our default).
prefs['group_role_map'] = { admins_group => admin_role_ids }.merge(prefs['group_role_map'] || {})

source.preferences    = prefs
source.active         = true
source.created_by_id ||= 1
source.updated_by_id   = 1
source.save!
" > "/var/log/$app/ldap-setup.log" 2>&1 \
        || ynh_print_warn "LDAP configuration did not complete — review /var/log/$app/ldap-setup.log and finish setup in Settings > System > Integrations > LDAP."
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
