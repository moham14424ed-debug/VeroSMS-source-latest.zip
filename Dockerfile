FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV FLASK_CONFIG=production
ENV LEGACY_FLASK=true
ENV PYTHON_BIN=/opt/verosms-venv/bin/python
ENV FLASK_PORT=5050

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-pip \
        unzip \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY source.zip /tmp/source.zip

RUN set -eux; \
    test -s /tmp/source.zip; \
    unzip -t /tmp/source.zip >/dev/null; \
    mkdir -p /tmp/verosms-source; \
    unzip -q /tmp/source.zip -d /tmp/verosms-source; \
    PROJECT_ROOT="$(find /tmp/verosms-source -path '*/node_modules' -prune -o -path '*/dist' -prune -o -type f -name package.json -print -quit | xargs -r dirname)"; \
    test -n "$PROJECT_ROOT"; \
    cp -a "$PROJECT_ROOT"/. /app/; \
    test -f /app/package.json; \
    test -f /app/pnpm-lock.yaml; \
    test -f /app/legacy_flask/requirements.txt; \
    python3 -m venv /opt/verosms-venv; \
    /opt/verosms-venv/bin/pip install --no-cache-dir --upgrade pip; \
    /opt/verosms-venv/bin/pip install --no-cache-dir -r /app/legacy_flask/requirements.txt; \
    npm install --global pnpm@10.4.1; \
    pnpm install --frozen-lockfile; \
    pnpm run build; \
    rm -rf /tmp/verosms-source /tmp/source.zip

EXPOSE 3000

CMD ["node", "dist/index.js"]
