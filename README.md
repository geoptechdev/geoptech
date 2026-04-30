# Laravel + MariaDB for Magic Containers

A Laravel app with MariaDB, ready to deploy on [Bunny Magic Containers](https://bunny.net/magic-containers/).

## What's included

- `Dockerfile` - PHP 8.4 FPM + Nginx in a single container using supervisord
- `docker/nginx.conf` - Nginx config for Laravel
- `docker/supervisord.conf` - Runs PHP-FPM and Nginx together
- `docker/entrypoint.sh` - Caches config, waits for the database, runs migrations, then starts the server
- `docker-compose.yml` - Local development setup with app and MariaDB
- `bunny.json` - Magic Containers app config with app and database containers
- `.github/workflows/deploy.yml` - GitHub Actions workflow to build, push to GitHub Container Registry, and deploy to Magic Containers

## Run locally

```bash
docker compose up --build
```

Visit [http://localhost:8000](http://localhost:8000).

Run migrations on first start:

```bash
docker compose exec app php artisan migrate
```

## Deploy to Magic Containers

### 1. Fork and push

Fork this repository and push to the `main` branch. The GitHub Actions workflow will automatically build the Docker image and push it to `ghcr.io/<your-username>/mc-template-laravel` tagged with both `latest` and the commit SHA.

### 2. Generate an app key

Generate a Laravel app key to use in your deployment:

```bash
php artisan key:generate --show
```

Update the `APP_KEY` value in `bunny.json` with the generated key, or set it as an environment variable in the Magic Containers dashboard.

### 3. Make the package public

Go to your GitHub profile > **Packages** > select the `mc-template-laravel` package > **Package settings** > change visibility to **Public**.

### 4. Create an app on Magic Containers

1. Log in to the [bunny.net dashboard](https://dash.bunny.net) and navigate to **Magic Containers**.
2. Click **Create App**.
3. Add the **app** container:
   - **Registry**: GitHub Container Registry (`ghcr.io`)
   - **Image**: `ghcr.io/<your-username>/mc-template-laravel:latest`
   - Add an **Endpoint** on port `80`
   - Set the environment variables (`APP_KEY`, `APP_ENV`, `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`)
4. Add the **db** container:
   - **Image**: `mariadb:11`
   - Set the environment variables (`MARIADB_DATABASE`, `MARIADB_USER`, `MARIADB_PASSWORD`, `MARIADB_ROOT_PASSWORD`)
   - Add a **Volume** mounted at `/var/lib/mysql`
5. Confirm and deploy.

### 5. Test it

Once deployed, you'll get a `*.bunny.run` URL:

```bash
curl https://mc-xxx.bunny.run
```

## Continuous deployment

The workflow automatically deploys to Magic Containers on every push to `main`. Configure the following in your repository settings:

- **Variable** `APP_ID` - your Magic Containers app ID
- **Secret** `BUNNYNET_API_KEY` - your bunny.net API key

## Important notes for Magic Containers

- **`DB_HOST` must be `127.0.0.1`, not `localhost`** - Magic Containers share a localhost network between containers. However, PHP/PDO interprets `localhost` as a Unix socket connection, which fails. Always use `127.0.0.1` to force TCP.
- **Don't cache config at build time** - The `Dockerfile` does not run `php artisan config:cache`. Config is cached at container startup via the entrypoint script so it picks up runtime environment variables.
- **`.env` is excluded from the image** - The `.dockerignore` excludes `.env` so environment variables from Magic Containers take effect. The entrypoint creates an empty `.env` file at startup.
- **Migrations run automatically** - The entrypoint waits for MariaDB to be ready, then runs `php artisan migrate --force` on every container start.
