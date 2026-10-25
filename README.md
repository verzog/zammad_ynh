# Zammad for YunoHost

[![Install with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=zammad)

*Customer support and helpdesk ticketing system.*

> This is a YunoHost package. To use it you need a working
> [YunoHost](https://yunohost.org) server (11.2.29 or newer). See the
> [packaging docs](https://yunohost.org/packaging_apps) if you are new to this.

## Overview

[Zammad](https://zammad.org) is a web-based, open-source helpdesk and customer
support system with many features for managing customer communication across
several channels (email, chat, telephone, social media).

This package:

- installs Zammad from its official Debian package
  ([packager.io](https://packager.io/gh/zammad/zammad)), which brings in
  PostgreSQL, Redis and Ruby/Rails,
- installs and starts **Elasticsearch 8.x** automatically (capped to a 512 MB
  heap) because the Zammad package depends on it,
- serves Zammad through YunoHost's NGINX (including the WebSocket and Action
  Cable endpoints for live ticket updates),
- **automatically configures LDAP** against YunoHost's directory so users sign
  in with their YunoHost accounts (users sync as Customers; promote to agent/admin
  in the LDAP integration page — see [`doc/DISCLAIMER.md`](doc/DISCLAIMER.md)),
- adds Fail2ban and logrotate integration, and registers the Zammad service
  with the YunoHost webadmin.

**Shipped version:** 7.2.2

## Important notes

- **Installation takes 5–15 minutes** (DB migrations run on first boot).
- Zammad must be installed at the **root of a dedicated (sub)domain**
  (e.g. `support.example.com`), not in a subpath.
- See [`doc/DISCLAIMER.md`](doc/DISCLAIMER.md) for system requirements, the
  initial admin credentials, LDAP sync, backup/restore and troubleshooting.

## Documentation and resources

- Upstream app website: <https://zammad.org>
- Upstream documentation: <https://docs.zammad.org>
- Upstream code repository: <https://github.com/zammad/zammad>

## Developer info

Please send your pull requests to the `vdiddy/charming-hopper-a5zlqw` /
`master` branch.

To try the development branch:

```bash
sudo yunohost app install https://github.com/verzog/zammad_ynh/tree/master --debug
# or
sudo yunohost app upgrade zammad -u https://github.com/verzog/zammad_ynh/tree/master --debug
```

**More info regarding app packaging:** <https://yunohost.org/packaging_apps>
