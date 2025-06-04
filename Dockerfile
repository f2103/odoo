FROM odoo:17.0

ARG LOCALE=en_US.UTF-8

ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LANG=${LOCALE}

USER 0

# Installiere benötigte Pakete
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends locales netcat-openbsd git \
    && locale-gen ${LOCALE}

# Erstelle das Verzeichnis für OCA-Addons
RUN mkdir -p /opt/odoo/custom_addons

# Klone alle benötigten OCA-Repositories
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/server-tools.git /opt/odoo/custom_addons/server-tools
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/mis-builder.git /opt/odoo/custom_addons/mis-builder
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/web.git /opt/odoo/custom_addons/web
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/account-financial-tools.git /opt/odoo/custom_addons/account-financial-tools
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/project.git /opt/odoo/custom_addons/project
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/hr.git /opt/odoo/custom_addons/hr
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/timesheet.git /opt/odoo/custom_addons/timesheet
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/purchase-workflow.git /opt/odoo/custom_addons/purchase-workflow
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/account-invoicing.git /opt/odoo/custom_addons/account-invoicing
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/account-financial-reporting.git /opt/odoo/custom_addons/account-financial-reporting
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/account-reconcile.git /opt/odoo/custom_addons/account-reconcile
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/account-payment.git /opt/odoo/custom_addons/account-payment

WORKDIR /app

COPY --chmod=755 entrypoint.sh ./

ENTRYPOINT ["/bin/sh"]
CMD ["entrypoint.sh"]
