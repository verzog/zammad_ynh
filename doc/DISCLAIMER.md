## Notes

### Installation time

Zammad installs via its official Debian package, which pulls in PostgreSQL, Redis, Ruby, and all Rails dependencies. **Expect the initial installation to take 5–15 minutes** depending on your server's speed and internet connection.

### Minimum system requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU      | 2 cores | 4 cores     |
| RAM      | 2 GB    | 4 GB        |
| Disk     | 5 GB    | 20 GB+      |

### Root domain installation

Zammad works best when installed at the **root of a dedicated domain** (e.g., `support.example.com/`), not in a subdirectory. Installing at a subpath may cause issues with asset loading and redirects.

### Elasticsearch

This package **installs and starts Elasticsearch 8.x automatically** during
installation (its JVM heap is capped at 512 MB to suit a typical VPS), because
the Zammad Debian package depends on it. You do not need to install it yourself.

If search is not returning results, point Zammad at it in the admin panel under
**Settings → Integrations → Elasticsearch → URL: `http://localhost:9200`** and
trigger a rebuild of the search index.

### LDAP / YunoHost user sync

This package **automatically configures** Zammad to authenticate against
YunoHost's LDAP directory, so users can sign in with their YunoHost accounts.
Installation enables the `ldap_integration` setting and creates an LDAP source
named **YunoHost** with these parameters:

| Field       | Value                          |
|-------------|--------------------------------|
| Host / Port | `localhost` : `389` (no SSL)   |
| Base DN     | `ou=users,dc=yunohost,dc=org`  |
| Bind user   | *(empty — anonymous read)*     |
| User filter | `(objectClass=posixAccount)`   |
| UID         | `uid` → login                  |
| First name  | `givenName` → firstname        |
| Last name   | `sn` → lastname                |
| Email       | `mail` → email                 |

Zammad's `Import::Ldap` backend then syncs users automatically on its schedule
(the first sync runs within a few minutes of install; no manual trigger needed).

**Roles:** synced users receive Zammad's default signup role (**Customer**). To
make selected YunoHost users agents or admins, add a group→role mapping (or set
individual roles) under **Admin panel → System → Integrations → LDAP**.

**If your YunoHost LDAP does not allow anonymous reads**, edit the same page and
supply a bind DN and password; everything else is already filled in.

### Admin credentials

The initial admin password is stored in YunoHost app settings and can be retrieved with:

```bash
yunohost app setting zammad admin_password
```

It is recommended to change this password after first login via **Profile → Password**.

### Backup and restore

This package uses Zammad's official backup script (`/opt/zammad/contrib/backup/zammad_backup.sh`) when available, which captures both the database and file attachments. Manual backups can be triggered with:

```bash
sudo -u zammad bash /opt/zammad/contrib/backup/zammad_backup.sh
```

### Troubleshooting

Check service status:
```bash
systemctl status zammad-web zammad-worker zammad-websocket
```

View logs:
```bash
journalctl -u zammad-web -f
tail -f /var/log/zammad/production.log
```

Restart all Zammad services:
```bash
systemctl restart zammad
```
