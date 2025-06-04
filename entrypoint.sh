#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo Database is now available

ODOO_MAJOR=${ODOO_VERSION:-17.0}          # set ODOO_VERSION=18.0 when you switch images
EXTRA_ADDONS=/mnt/extra-addons

if [ -n "$OCA_REPOS" ]; then
  mkdir -p "$EXTRA_ADDONS"
  IFS=',' read -ra repos <<< "$OCA_REPOS"
  for r in "${repos[@]}"; do
    echo "→ cloning OCA/$r (branch $ODOO_MAJOR)"
    git clone --depth 1 --branch "$ODOO_MAJOR" \
      "https://github.com/OCA/$r.git" "$EXTRA_ADDONS/$r"
  done
  chown -R odoo:odoo "$EXTRA_ADDONS"
fi

BASE_ADDONS=/usr/lib/python3/dist-packages/odoo/addons
ADDONS_PATH="$BASE_ADDONS,$EXTRA_ADDONS"

exec odoo \
    --http-port="${PORT}" \
    --init=all \
    --without-demo=True \
    --proxy-mode \
    --db_host="${ODOO_DATABASE_HOST}" \
    --db_port="${ODOO_DATABASE_PORT}" \
    --db_user="${ODOO_DATABASE_USER}" \
    --db_password="${ODOO_DATABASE_PASSWORD}" \
    --database="${ODOO_DATABASE_NAME}" \
    --smtp="${ODOO_SMTP_HOST}" \
    --smtp-port="${ODOO_SMTP_PORT_NUMBER}" \
    --smtp-user="${ODOO_SMTP_USER}" \
    --smtp-password="${ODOO_SMTP_PASSWORD}" \
    --email-from="${ODOO_EMAIL_FROM}" 2>&1
