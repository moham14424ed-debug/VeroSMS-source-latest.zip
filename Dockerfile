FROM node:22-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-venv unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY source.zip /tmp/source.zip

RUN unzip -q /tmp/source.zip -d /app \
    && test -f /app/package.json \
    && python3 -m venv /opt/verosms-venv \
    && /opt/verosms-venv/bin/pip install --no-cache-dir -r /app/legacy_flask/requirements.txt \
    && npm install -g pnpm@10.4.1 \
    && pnpm install --frozen-lockfile \
    && pnpm run build \
    && rm -f /tmp/source.zip

ENV NODE_ENV=production
ENV FLASK_CONFIG=production
ENV LEGACY_FLASK=true
ENV PYTHON_BIN=/opt/verosms-venv/bin/python
ENV FLASK_PORT=5050

EXPOSE 3000

CMD ["node", "dist/index.js"]
