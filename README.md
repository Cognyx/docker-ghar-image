# GHAR (DinD) runner image

D-in-D image for GitHub Actions Self-Hoster runner based on [summerwind/actions-runner-dind](https://hub.docker.com/r/summerwind/actions-runner-dind)

## Packages

| Package                                | Version     | Version CLI                |
| -------------------------------------- | ----------- | -------------------------- |
| **Ubuntu (Base OS)**                   | `24.04 LTS` | `cat /etc/os-release`      |
| **GitHub Actions Runner (summerwind)** | `2.335.1`   | `/runner/run.sh --version` |
| **Golang**                             | `1.25.3`    | `go version`               |
| **Buildx**                             | `0.35.0`    | `docker buildx version`    |
| **Node.js**                            | `24.x`      | `node --version`           |
| **npm**                                | `11.6.2`    | `npm --version`            |
| **pnpm**                               | `10.33.0`   | `pnpm --version`           |
| **Wrangler**                           | `3.56.0`    | `npx wrangler --version`   |
| **Firebase CLI**                       | `15.13.0`   | `firebase --version`       |
| **GitHub CLI (gh)**                    | `2.89.0`    | `gh --version`             |
| **Playwright**                         | `1.58.2`    | `npx playwright --version` |
| **kubectl**                            | `latest`    | `kubectl version --client` |
| **Helm**                               | `latest`    | `helm version`             |

- wget, curl, unzip, git, libpq-dev, build-essential, libvips-dev, pkg-config

## Run

`docker run -it --entrypoint=bash --rm eu.gcr.io/cognyx-471812/ghar-image:latest`

## Build

- `docker buildx build -t ghar-image .`
