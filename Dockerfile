FROM odoo:17.0

ARG LOCALE=en_US.UTF-8

ENV LANGUAGE=${LOCALE}
ENV LC_ALL=${LOCALE}
ENV LANG=${LOCALE}

# Installiere git und andere benötigte Pakete
USER 0
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends locales netcat-openbsd git \
    && locale-gen ${LOCALE}

# Erstelle das Verzeichnis für OCA-Addons
RUN mkdir -p /opt/odoo/custom_addons

# Klone OCA-Addons (Beispiel: partner-contact und website)
# Passe die Branches an, falls du eine andere Odoo-Version verwendest!
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/partner-contact.git /opt/odoo/custom_addons/partner-contact \
    && git clone --depth 1 --branch 17.0 https://github.com/OCA/website.git /opt/odoo/custom_addons/website

# Optional: Weitere OCA-Addons hinzufügen
# RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/<REPOSITORY>.git /opt/odoo/custom_addons/<REPOSITORY>

WORKDIR /app

COPY --chmod=755 entrypoint.sh ./

ENTRYPOINT ["/bin/sh"]
CMD ["entrypoint.sh"]
