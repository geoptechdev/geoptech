#!/bin/sh
cd /var/www/html

touch .env

php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Waiting for database..."
until php artisan db:monitor --databases=mariadb > /dev/null 2>&1; do
    sleep 1
done
echo "Database is ready."

php artisan migrate --force

exec supervisord -c /etc/supervisord.conf
