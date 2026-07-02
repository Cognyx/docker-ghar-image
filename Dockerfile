FROM docker.io/library/golang:1.25.3 AS golang
FROM docker.io/docker/buildx-bin:0.35.0 AS buildx
FROM docker.io/summerwind/actions-runner-dind:v2.335.1-ubuntu-24.04
USER root
COPY --from=golang "/usr/local/go/" "/usr/local/go/"
COPY --from=buildx /buildx /usr/libexec/docker/cli-plugins/docker-buildx
ENV PATH="/usr/local/go/bin:${PATH}"
ENV PLAYWRIGHT_BROWSERS_PATH="/ms-playwright"

RUN set -ex; \
  export DEBIAN_FRONTEND=noninteractive; \
  # Setup Node.js repository
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash -; \
  \
  # Add GitHub CLI repository
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; \
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list; \
  \
  # Update and install all packages
  apt-get update; \
  apt-get install --no-install-recommends --no-install-suggests -y \
  gh \
  nodejs \
  git unzip libpq-dev build-essential libvips-dev pkg-config; \
  \
  # Setup Node packages
  npm install -g pnpm wrangler@3.56.0 firebase-tools; \
  \
  # Install Kubernetes tools
  echo "Installing kubectl..."; \
  curl -fsSLO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
  rm kubectl; \
  \
  echo "Installing Helm..."; \
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
  \
  echo "Installing Playwright and Chromium dependencies..."; \
  npm install -g playwright@1.58.2; \
  npx playwright install --with-deps chromium; \
  chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH; \
  npm cache clean --force; \
  chown -R 1001:1001 /home/runner/.npm /home/runner/.cache || true; \
  \
  # Cleanup apt caches aggressively
  apt-get clean autoclean; \
  apt-get autoremove --yes; \
  rm -rf /var/lib/apt/lists/*

# Dynamically append whatever is in CUSTOM_FLAGS to the GitHub registration command
RUN sed -i 's/--labels "${RUNNER_LABELS}"/--labels "${RUNNER_LABELS}" ${CUSTOM_FLAGS}/g' /usr/bin/startup.sh

USER runner
RUN echo "PATH=$PATH" >> /runnertmp/.env
