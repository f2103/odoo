#!/bin/sh

set -e

echo Waiting for database...

while ! nc -z ${ODOO_DATABASE_HOST} ${ODOO_DATABASE_PORT} 2>&1; do sleep 1; done; 

echo Database is now available

if [ -n "$OCA_REPOS" ]; then
  mkdir -p /mnt/extra-addons
  IFS=',' read -ra repos <<< "$OCA_REPOS"
  for r in "${repos[@]}"; do
    echo "→ Klone OCA/$r"
    git clone --depth 1 --branch 17.0 https://github.com/OCA/$r.git /mnt/extra-addons/$r
  done
  chown -R odoo:odoo /mnt/extra-addons
  export ODOO_ADDONS_PATH="/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons"
fi

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
