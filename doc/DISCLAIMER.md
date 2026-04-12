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

### Elasticsearch (optional but recommended)

By default Zammad uses PostgreSQL full-text search, which is functional but slow on large ticket volumes. For production use, install Elasticsearch separately and configure it in Zammad's admin panel under **Settings → Integrations → Elasticsearch**.

```bash
# Quick Elasticsearch setup (run as root after Zammad install)
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor > /usr/share/keyrings/elasticsearch.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elasticsearch.list
apt-get update && apt-get install -y elasticsearch
systemctl enable --now elasticsearch
```

Then in Zammad admin panel: **Settings → Integrations → Elasticsearch → URL: http://localhost:9200**

### LDAP / YunoHost user sync

This package automatically configures Zammad to read users from YunoHost's LDAP directory. Users can log in with their YunoHost credentials. The sync runs automatically when users first log in.

To manually trigger a full sync: **Admin panel → Users → (LDAP sync button)**.

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
