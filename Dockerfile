# Build stage for sao (Tryton web client)
FROM node:18-slim AS sao-builder

WORKDIR /sao

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy sao source
COPY sao/package.json sao/bower.json ./
COPY sao/ ./

# Install dependencies and build
# Use --allow-root for bower and disable SSL verification for git
RUN git config --global http.sslVerify false && \
    npm install --legacy-peer-deps && \
    npx bower install --allow-root && \
    npx grunt

# Main stage
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

# Copy built sao web client from builder stage
# Include all necessary files: index.html, dist, bower_components, images, locale, sounds
COPY --from=sao-builder /sao/index.html /app/www/index.html
COPY --from=sao-builder /sao/dist /app/www/dist
COPY --from=sao-builder /sao/bower_components /app/www/bower_components
COPY --from=sao-builder /sao/images /app/www/images
COPY --from=sao-builder /sao/locale /app/www/locale
COPY --from=sao-builder /sao/sounds /app/www/sounds

COPY trytond.conf /app/trytond.conf
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8001

ENV TRYTOND_CONFIG=/app/trytond.conf

HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
    CMD python -c "from xmlrpc.client import ServerProxy; s = ServerProxy('http://127.0.0.1:8001'); s.system.listMethods()" || exit 1

ENTRYPOINT ["/app/docker-entrypoint.sh"]
