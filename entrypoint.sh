#!/bin/sh

set -e

echo "Waiting for database..."
while ! nc -z "${ODOO_DATABASE_HOST}" "${0DOO_DATABASE_PORT}" 2>&1; do sleep 1; done;
echo "Database is now available"

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
    --email-from="${ODOO_EMAIL_FROM}" \
    --addons-path="/opt/odoo/addons,/opt/odoo/custom_addons/server-tools,/opt/odoo/custom_addons/mis-builder,/opt/odoo/custom_addons/web,/opt/odoo/custom_addons/account-financial-tools,/opt/odoo/custom_addons/project,/opt/odoo/custom_addons/resource_booking,/opt/odoo/custom_addons/hr,/opt/odoo/custom_addons/timesheet,/opt/odoo/custom_addons/purchase-workflow,/opt/odoo/custom_addons/account-invoicing,/opt/odoo/custom_addons/account-financial-reporting,/opt/odoo/custom_addons/account-reconcile,/opt/odoo/custom_addons/account-payment" 2>&1
