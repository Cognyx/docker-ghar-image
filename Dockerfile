# Tool versions Cognyx CI pins (go-version, node-version, python-version in
# Cognyx/cognyx .github). Keep them in sync: a version CI asks for that is not
# here is still downloaded by setup-go/node/python, only slower.
ARG GO_VERSION=1.27.3

FROM docker.io/library/golang:${GO_VERSION} AS golang

FROM ghcr.io/actions/actions-runner:2.338.2

ARG GO_VERSION
ARG NODE_VERSION=24.22.1
ARG NODE_SHA256=6c172a9ab6718f7b801fb5a7bd486af2ee5e32758086a04b84fcce2aa77095e6
ARG PYTHON_VERSION=3.13.15
ARG PYTHON_RELEASE=3.13.15-31064747964
ARG PYTHON_SHA256=4e544242f8a4ef647a6f511b67f9b00eefc9ef366644e3c40a27a6eff709ae2b
ARG SQLC_VERSION=1.30.0
ARG SQLC_SHA256=468aecee071bfe55e97fcbcac52ea0208eeca444f67736f3b8f0f3d6a106132e

# Tool cache for actions/setup-go, setup-node and setup-python: a version found here
# (<tool>/<version>/x64 plus x64.complete) is used without a download. It must sit
# outside /home/runner/_work, which ARC mounts as an empty volume. The runner reads
# RUNNER_TOOL_CACHE first (actions/runner HostContext.cs).
ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

USER root
# Go lives in the tool cache; /usr/local/go points at it, so the default PATH and
# setup-go use the same copy.
COPY --from=golang "/usr/local/go/" "/opt/hostedtoolcache/go/${GO_VERSION}/x64/"
RUN ln -s "/opt/hostedtoolcache/go/${GO_VERSION}/x64" /usr/local/go; \
  touch "/opt/hostedtoolcache/go/${GO_VERSION}/x64.complete"
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
  # Update and install all packages. upgrade applies the base OS security fixes
  # (SCC OS_VULNERABILITY findings, COM-853 and COM-1264).
  apt-get update; \
  apt-get upgrade -y; \
  apt-get install --no-install-recommends --no-install-suggests -y \
  gh \
  nodejs \
  git unzip libpq-dev build-essential libvips-dev pkg-config; \
  \
  # Setup Node packages
  npm install -g pnpm@11.8.0 wrangler@4.150.0 firebase-tools; \
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
  mkdir -p /home/runner/.npm /home/runner/.cache; \
  chown -R 1001:1001 /home/runner/.npm /home/runner/.cache || true; \
  \
  # Cleanup apt caches aggressively
  apt-get clean autoclean; \
  apt-get autoremove --yes; \
  rm -rf /var/lib/apt/lists/*

# Node and Python for the tool cache, the same builds setup-node and setup-python
# download, checked against pinned hashes. sqlc for the API's generated-code check,
# which otherwise builds it with go install (about 70 s).
RUN set -ex; \
  cd /tmp; \
  curl -fsSLo node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"; \
  echo "${NODE_SHA256}  node.tar.xz" | sha256sum -c -; \
  mkdir -p "/opt/hostedtoolcache/node/${NODE_VERSION}/x64"; \
  tar -xJf node.tar.xz --strip-components=1 -C "/opt/hostedtoolcache/node/${NODE_VERSION}/x64"; \
  touch "/opt/hostedtoolcache/node/${NODE_VERSION}/x64.complete"; \
  rm node.tar.xz; \
  \
  curl -fsSLo python.tar.gz "https://github.com/actions/python-versions/releases/download/${PYTHON_RELEASE}/python-${PYTHON_VERSION}-linux-24.04-x64.tar.gz"; \
  echo "${PYTHON_SHA256}  python.tar.gz" | sha256sum -c -; \
  mkdir python; \
  tar -xzf python.tar.gz -C python; \
  # setup.sh ships without the execute bit.
  (cd python && bash ./setup.sh); \
  rm -rf python python.tar.gz /root/.cache/pip; \
  \
  curl -fsSLo sqlc.tar.gz "https://github.com/sqlc-dev/sqlc/releases/download/v${SQLC_VERSION}/sqlc_${SQLC_VERSION}_linux_amd64.tar.gz"; \
  echo "${SQLC_SHA256}  sqlc.tar.gz" | sha256sum -c -; \
  tar -xzf sqlc.tar.gz -C /usr/local/bin sqlc; \
  rm sqlc.tar.gz; \
  \
  # setup-* add versions that are missing here, as the runner user.
  chown -R 1001:1001 /opt/hostedtoolcache

ARG DOCKER_COMPOSE_VERSION=v5.5.0

# Install Docker Compose v2 plugin
RUN set -ex; \
  mkdir -p /usr/local/lib/docker/cli-plugins; \
  curl -fLo /usr/local/lib/docker/cli-plugins/docker-compose \
  "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)"; \
  chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

USER runner
RUN echo "PATH=$PATH" >> /home/runner/.env
