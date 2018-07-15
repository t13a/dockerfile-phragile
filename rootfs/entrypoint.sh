#!/bin/sh

set -euo pipefail

if [ -n "${TIMEZONE:-}" ]
then
    ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
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
    echo "${SNAPSHOTS_CREATE_SCHEDULE} php /phragile/artisan snapshots:create" > /cron/root
fi

exec "${@}"
