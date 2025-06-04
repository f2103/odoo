#!/usr/bin/env bash
set -euo pipefail
# set -x            # <-- uncomment if you want bash to echo every step

###############################################################################
# 0. Wait until Postgres REALLY answers SQL, not just TCP
###############################################################################
echo "⏳ Waiting for PostgreSQL at ${ODOO_DATABASE_HOST}:${ODOO_DATABASE_PORT} …"
until pg_isready -h "${ODOO_DATABASE_HOST}" -p "${ODOO_DATABASE_PORT}" -U "${ODOO_DATABASE_USER}" >/dev/null 2>&1
do sleep 1; done
echo "✅ Database is ready"

###############################################################################
# 1. Clone extra add-ons only once per container start-up
###############################################################################
if [ -n "${OCA_REPOS:-}" ]; then
  mkdir -p /mnt/extra-addons
  IFS=',' read -ra repos <<< "${OCA_REPOS}"
  for r in "${repos[@]}"; do
    echo "→ Cloning OCA/${r}"
    git clone --depth 1 --branch 17.0 "https://github.com/OCA/${r}.git" "/mnt/extra-addons/${r}"
  done
  chown -R odoo:odoo /mnt/extra-addons
  export ODOO_ADDONS_PATH="/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons"
fi

###############################################################################
# 2. Build the dynamic CLI flags – only if values exist
###############################################################################
odoo_flags=(
  "--http-port=${PORT:-8069}"
  "--without-demo=all"
  "--proxy-mode"
  "--db_host=${ODOO_DATABASE_HOST}"
  "--db_port=${ODOO_DATABASE_PORT}"
  "--db_user=${ODOO_DATABASE_USER}"
  "--db_password=${ODOO_DATABASE_PASSWORD}"
  "--database=${ODOO_DATABASE_NAME}"
)

# optional e-mail flags (avoid empty ones!)
[ -n "${ODOO_SMTP_HOST:-}" ]       && odoo_flags+=( "--smtp=${ODOO_SMTP_HOST}" )        #  smtp server           :contentReference[oaicite:1]{index=1}
[ -n "${ODOO_SMTP_PORT_NUMBER:-}" ]&& odoo_flags+=( "--smtp-port=${ODOO_SMTP_PORT_NUMBER}" )
[ -n "${ODOO_SMTP_USER:-}" ]       && odoo_flags+=( "--smtp-user=${ODOO_SMTP_USER}" )
[ -n "${ODOO_SMTP_PASSWORD:-}" ]   && odoo_flags+=( "--smtp-password=${ODOO_SMTP_PASSWORD}" )
[ -n "${ODOO_EMAIL_FROM:-}" ]      && odoo_flags+=( "--email-from=${ODOO_EMAIL_FROM}" )

# optional first-run module list (NEVER all of them in prod)
[ -n "${ODOO_INIT_MODULES:-}" ]    && odoo_flags+=( "--init=${ODOO_INIT_MODULES}" )

###############################################################################
# 3. Finally run Odoo (PID 1) – Bash is replaced by odoo-bin
###############################################################################
echo "🚀 Starting Odoo with: ${odoo_flags[*]}"
exec odoo "${odoo_flags[@]}"
