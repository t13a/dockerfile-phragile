#!/bin/sh

set -euo pipefail

if [ -n "${TIMEZONE:-}" ]
then
    cp -f "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    echo "${TIMEZONE}" > /etc/timezone

    sed -irf /phragile/config/app.php \
    "s/^(\\s*'timezone'\\s*=>\\s*)'UTC'(\\s*,)/\\1env('TIMEZONE', 'UTC')\\2/g"
fi

if [ -z "${NO_MIGRATE:-}" ]
then
    (
        cd /phragile
        php artisan migrate --force
    )
fi

if [ -z "${NO_PREPARE_STORAGE:-}" ]
then
    (
        cd /phragile/storage

        mkdir -p \
        app \
        framework \
        framework/cache \
        framework/sessions \
        framework/views \
        framework/logs

        chown -R www-data:www-data .
    )
fi

if [ -n "${SNAPSHOTS_CREATE_SCHEDULE:-}" ]
then
    echo "${SNAPSHOTS_CREATE_SCHEDULE} php /phragile/artisan snapshots:create" > /var/spool/cron/crontabs/www-data
fi

exec "${@}"
