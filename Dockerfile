FROM docker.io/library/golang:1.25.3 AS golang
FROM docker.io/library/composer:2.1.14 AS composer
FROM docker.io/docker/buildx-bin:0.30.1 AS buildx
FROM docker.io/summerwind/actions-runner-dind:v2.330.0-ubuntu-24.04
USER root
COPY --from=golang "/usr/local/go/" "/usr/local/go/"
COPY --from=composer "/usr/bin/composer" "/usr/local/bin/composer"
COPY --from=buildx /buildx /usr/libexec/docker/cli-plugins/docker-buildx
RUN set -ex; \
  curl -sL https://deb.nodesource.com/setup_24.x | bash -; \
  curl https://raw.githubusercontent.com/kadwanev/retry/0b65e6b7f54ed36b492910470157e180bbcc3c84/retry -o /usr/bin/retry; \
  chmod +x /usr/bin/retry; \
  # Add Ondrej PHP PPA for PHP 8.2
  add-apt-repository ppa:ondrej/php -y; \
  # Install GitHub CLI
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg; \
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list; \
  apt-get update; \
  apt-get install gh -y; \
  apt-get install --no-install-recommends --no-install-suggests -y \
  php8.2 php8.2-apcu php8.2-bcmath php8.2-dom php8.2-ctype php8.2-curl php8.2-exif php8.2-fileinfo php8.2-fpm \
  php8.2-gd php8.2-gmp php8.2-iconv php8.2-intl php-json php8.2-mbstring php8.2-mysqlnd php8.2-mysql php8.2-soap \
  php8.2-redis php8.2-mysqli php8.2-opcache php8.2-pdo php8.2-phar php8.2-posix php8.2-pdo-sqlite php8.2-simplexml \
  php8.2-sockets php8.2-sqlite3 php8.2-tidy php8.2-tokenizer php8.2-xml php8.2-xmlwriter php8.2-zip php8.2-dev \
  php-pear libgd-tools \
  nodejs \
  git unzip libpq-dev; \
  npm install -g n; \
  n 24.13.0; \
  ln -sf /usr/local/n/versions/node/24.13.0/bin/node /usr/bin/node; \
  ln -sf /usr/local/n/versions/node/24.13.0/bin/npm /usr/bin/npm; \
  ln -sf /usr/local/n/versions/node/24.13.0/bin/npx /usr/bin/npx; \
  npm install -g pnpm wrangler@3.56.0 firebase-tools; \
  \
  # ---- Install Kubernetes tools ----
  echo "Installing kubectl..." && \
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl; \
  \
  echo "Installing Helm..." && \
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
  \
  echo "Installing Azure CLI..." && \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
  \
  apt-get clean autoclean; \
  apt-get autoremove --yes
# rm -rf /var/lib/{apt,dpkg,cache,log}/
# Force update-alternatives to use PHP 8.2
RUN update-alternatives --set php /usr/bin/php8.2 && \
  update-alternatives --set phar /usr/bin/phar8.2 && \
  update-alternatives --set phpize /usr/bin/phpize8.2 && \
  update-alternatives --set php-config /usr/bin/php-config8.2
ENV PATH="/usr/local/go/bin:${PATH}"
RUN chown -R 1001:1001 "/home/runner/"
USER runner
ENV PATH="/usr/local/go/bin:${PATH}"
RUN echo PATH=$PATH >> /runnertmp/.env
