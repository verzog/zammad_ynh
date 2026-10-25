Zammad is a web-based, open-source helpdesk and customer-support system that
lets a team handle requests from many channels in one place: email, web form,
chat, telephone (CTI) and social media all land as tickets in a shared inbox.

Key features:

- **Ticketing** with full history, notes, tags, macros and SLAs.
- **Multi-channel** intake: email (IMAP/POP/SMTP), web widget, live chat,
  Twitter/Facebook/Telegram, and phone integrations.
- **Knowledge base** for self-service documentation.
- **Powerful search and reporting**, backed by Elasticsearch.
- **Granular roles and permissions** for agents, customers and admins.
- **Automation** via triggers, schedulers and a REST API.

This package installs Zammad from its official Debian package (which brings in
PostgreSQL, Redis and Ruby/Rails) and automatically installs and starts the
Elasticsearch instance Zammad depends on. Zammad is served through YunoHost's
NGINX, with Fail2ban and logrotate integration and the service registered in
the YunoHost webadmin.

It is best installed at the root of a dedicated (sub)domain
(e.g. `support.example.com`), not in a subpath.
