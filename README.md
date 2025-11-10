# Drupal x Kamal

Minimal, production‑ready Drupal 11 for deployment with [Kamal][0].

## Features

Core:

- Based on the official [drupal/recommended-project][1] template (Drupal 11).
- Multi‑stage Docker build with [serversideup/php][2] (php‑fpm + nginx).
- Includes [Drush][3] for CLI administration.
- Redis module pre-required and ready for caching.

Deployment & Ops:

- Production and local Kamal deploy configs.
- Accessories: Redis (prod & local), MySQL (local).
- Persistent volume for `web/sites/default/files`.
- Serversideup/php exposes `/healthcheck`.
- Registry configuration + secrets via `.kamal/secrets`.
- Shell & Drush aliases (e.g., `kamal dcr`).

Configuration Management:

- Drupal config synchronization ready (YAML under `config/sync`).
- Export/import with Drush (`drush cex` / `drush cim`).

Security & Performance:

- Opcache enabled in production (see `PHP_OPCACHE_ENABLE=1`).
- Non-root runtime (runs as `www-data`).
- Slim Alpine base images.

Extensible:

- Easy to add accessories (e.g., Redis, DB, search) via Kamal.
- Env‑var driven PHP & Nginx tuning (see Dockerfile).

## Quick Start

### 1. Prerequisites

Install globally:

- Docker (Desktop or CLI)
- Ruby + Kamal gem (`gem install kamal`)
- A container registry account (Docker Hub, GHCR, etc.)
- A server (key-based SSH reachable).
- A DNS A record pointing to the server.

### 2. Clone & Inspect

```bash
git clone https://github.com/your-org/kamal-drupal.git
cd kamal-drupal
```

### 3. Configure Secrets

Kamal manages secrets under `.kamal/`. Don’t commit plain text secrets.
Inject secrets at deploy time using one or both methods described below.

If you have to use plain-text secrets, encrypt the secrets file (e.g., with git‑crypt)
before committing into version control.


#### Option A — Password manager (recommended)

Reference password manager entries in `.kamal/secrets` instead of raw values.
See example in `.kamal/secrets`.

#### Option B — Local .env environment variables

- Use `.env.example` as a template:

```bash
cp .env.example .env
```

- Fill values, then export to your shell so Kamal can read them:

```bash
set -a; source .env; set +a
```

### 4. Local Environment (Optional)

Local is for demonstration only and often needs extra tweaking. Prefer a VPS for dev/staging unless necessary.

Add to `/etc/hosts` for friendly domain:

```text
127.0.0.1 nara.localhost
```

Build & start locally using the local deploy config:

```bash
kamal setup -d local
kamal deploy -d local
```

### 6. Production Deploy

Ensure DNS for the host in `config/deploy.yml` (e.g. `nara.example.com`) points to your server.

```bash
kamal setup
kamal deploy
```

## Configuration

### Environment Variables

Defined under `env.clear` & `env.secret` in `config/deploy*.yml`.
Secrets are referenced by name and pulled from `.kamal/secrets` at deploy time.

### Volumes

Persistent user content:

```text
prod_kamal_drupal_files:/var/www/html/web/sites/default/files
local_kamal_drupal_files:/var/www/html/web/sites/default/files
```

Back up these volumes for disaster recovery.

### Redis

Reachable as `nara-redis`. Redis caching is enabled in `settings.kamal.php`.

### Config Sync

Post‑deploy runs `drush deploy` to update the DB, import config, and clear caches.

## Deployment Workflow

1. Code change (e.g. update `composer.json`).
2. Commit & push.
3. `kamal deploy` (build, push, update, health check).

Rollback:

```bash
kamal rollback
```

Shell into running container:

```bash
kamal shell
```

## References

- Kamal docs: <https://kamal-deploy.org>
- Serversideup PHP image: <https://serversideup.net/open-source/docker-php/>
- Drush: <https://www.drush.org>
- Drupal User Guide: <https://www.drupal.org/docs/user_guide/en/index.html>

[0]: https://kamal-deploy.org
[1]: https://github.com/drupal/recommended-project
[2]: https://github.com/serversideup/docker-php
[3]: https://github.com/drush-ops/drush
