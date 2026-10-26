FROM node:24.19.0-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
# Public Firebase configuration and the licensed client key are injected only
# for compilation. The local env file never becomes a deployed file.
RUN --mount=type=secret,id=ops_env,target=/app/.env.local npm run build
RUN mkdir -p /bundle/.next && cp -a .next/standalone/. /bundle/ && \
    cp -a .next/static /bundle/.next/static && cp -a public /bundle/public && \
    rm -f /bundle/.env.local && cp /usr/local/bin/node /bundle/node
FROM scratch AS bundle
COPY --from=build /bundle/ /
