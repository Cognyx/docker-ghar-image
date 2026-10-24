# GHAR runner image

Custom GitHub Actions Self-Hosted runner image for CI/CD workflows, built on the official
GitHub Actions runner image (`ghcr.io/actions/actions-runner`).

## Packages

| Package                                | Version     | Version CLI                |
| -------------------------------------- | ----------- | -------------------------- |
| **Ubuntu (Base OS)**                   | `24.04 LTS` | `cat /etc/os-release`      |
| **GitHub Actions Runner**              | `2.338.1`   | `/home/runner/run.sh --version` |
| **Golang**                             | `1.27.3`    | `go version`               |
| **Node.js**                            | `24.x`      | `node --version`           |
| **pnpm**                               | `11.8.0`    | `pnpm --version`           |
| **Wrangler**                           | `4.150.0`   | `npx wrangler --version`   |
| **Firebase CLI**                       | `latest`    | `firebase --version`       |
| **GitHub CLI (gh)**                    | `latest`    | `gh --version`             |
| **Playwright**                         | `1.58.2`    | `npx playwright --version` |
| **kubectl**                            | `latest`    | `kubectl version --client` |
| **Helm**                               | `latest`    | `helm version`             |
| **Docker Compose**                     | `v5.5.0`    | `docker compose version`   |

- wget, curl, unzip, git, libpq-dev, build-essential, libvips-dev, pkg-config

## Build

```bash
docker buildx build -t ghar-image .
```

## Run

```bash
docker run -it --entrypoint=bash --rm ghar-image:latest
```

## Notes

- Docker-in-Docker is provided by a sidecar container (infra), not this image.
- The runner `PATH` env file lives at `/home/runner/.env`.
- The image is pushed to `eu.gcr.io/cognyx-471812/ghar-image:latest` (plus `{{branch}}-{{sha}}-{{date}}`).
