FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libxml2-dev \
    libxslt1-dev \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY trytond /app/trytond
COPY proteus /app/proteus
COPY modules /app/modules

RUN pip install --no-cache-dir \
    psycopg2-binary>=2.7.0 \
    defusedxml \
    lxml>=2.0 \
    relatorio[fodt]>=0.7.0 \
    Genshi \
    python-dateutil \
    polib \
    python-sql>=1.5 \
    simpleeval \
    werkzeug>=0.12 \
    "pwdlib[argon2]>=0.2" \
    && pip install --no-cache-dir /app/trytond \
    && pip install --no-cache-dir /app/proteus

COPY trytond.conf /app/trytond.conf
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8001

ENV TRYTOND_CONFIG=/app/trytond.conf

HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
    CMD python -c "from xmlrpc.client import ServerProxy; s = ServerProxy('http://127.0.0.1:8001'); s.system.listMethods()" || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
