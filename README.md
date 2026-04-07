# GHAR (DinD) runner image

D-in-D image for GitHub Actions Self-Hoster runner based on [summerwind/actions-runner-dind](https://hub.docker.com/r/summerwind/actions-runner-dind)

## Packages

| Package                                | Version     | Version CLI                |
| -------------------------------------- | ----------- | -------------------------- |
| **Ubuntu (Base OS)**                   | `24.04 LTS` | `cat /etc/os-release`      |
| **GitHub Actions Runner (summerwind)** | `2.333.0`   | `/runner/run.sh --version` |
| **Golang**                             | `1.25.3`    | `go version`               |
| **Buildx**                             | `0.30.1`    | `docker buildx version`    |
| **Node.js**                            | `24.13.0`   | `node --version`           |
| **npm**                                | `11.6.2`    | `npm --version`            |
| **Composer**                           | `2.1.14`    | `composer --version`       |
| **PHP**                                | `8.2.30`    | `php --version`            |
| **pnpm**                               | `10.33.0`   | `pnpm --version`           |
| **Firebase CLI**                       | `15.13.0`   | `firebase --version`       |
| **GitHub CLI (gh)**                    | `2.89.0`    | `gh --version`             |
| **Playwright**                         | `1.58.2`    | `gh --version`             |

- php-apcu, php-bcmath, php-dom, php-ctype, php-curl, php-exif, php-fileinfo, php-fpm, php-gd, php-gmp, php-iconv, php-intl, php-json, php-mbstring, php-mysqlnd, php-soap, php-redis, php-mysqli, php-opcache, php-pdo, php-phar, php-posix, php-simplexml, php-sockets, php-sqlite3, php-tidy, php-tokenizer, php-xml, php-xmlwriter, php-zip, php-pear, libgd-tools

- wget, curl, unzip

## Run

`docker run -it --entrypoint=bash --rm eu.gcr.io/cognyx-471812/ghar-image:latest`

## Build

- `docker buildx build -t ghar-image .`
