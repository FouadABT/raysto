# Build from the project root with:
# docker build -f raysto_server/Dockerfile .

# Build stage
FROM node:24.19.0-bookworm-slim AS paypal-mcp
WORKDIR /paypal-mcp
COPY raysto_server/paypal_mcp_runtime/package*.json ./
RUN npm ci --omit=dev --ignore-scripts --no-audit --no-fund \
    && find node_modules -type d -name .bin -prune -exec rm -rf '{}' +
COPY raysto_server/paypal_mcp_runtime/verify-contract.cjs ./
RUN node verify-contract.cjs

FROM dart:3.13.7 AS build

# Create a minimal workspace that preserves locked server dependency versions.
WORKDIR /app
COPY pubspec.lock .
COPY raysto_server raysto_server
RUN printf '%s\n' \
  'name: raysto_backend_container' \
  'environment:' \
  '  sdk: ^3.13.0' \
  'workspace:' \
  '  - raysto_server' \
  > pubspec.yaml
RUN dart pub get

# Compile the server executable.
WORKDIR /app/raysto_server
RUN dart build cli --target bin/main.dart --output build
RUN mv build/bundle/bin/main build/bundle/bin/server

# Add a fallback for the copy of possibly missing directories.
RUN mkdir -p config web migrations

# Final stage
FROM alpine:3.24
WORKDIR /app

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

# Copy runtime dependencies
COPY --from=build /runtime/ /

# Copy compiled server executable and native libraries
COPY --from=build /app/raysto_server/build/bundle/ ./

# Project-local official MCP runtime; no npm downloads at server startup.
COPY --from=paypal-mcp /usr/local/bin/node /app/lib/paypal-mcp/node
COPY --from=paypal-mcp /paypal-mcp/ /app/lib/paypal-mcp/
# Node needs these in addition to the Dart runtime's C libraries.
COPY --from=paypal-mcp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/
COPY --from=paypal-mcp /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/

# Copy configuration files and resources
COPY --from=build /app/raysto_server/config/ config/
COPY --from=build /app/raysto_server/web/ web/
COPY --from=build /app/raysto_server/migrations/ migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /app/raysto_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml
COPY --chmod=755 raysto_server/docker-entrypoint.sh /app/docker-entrypoint.sh

# Expose ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

USER 65532:65532

# Define the entrypoint command
ENTRYPOINT ["/app/docker-entrypoint.sh"]
