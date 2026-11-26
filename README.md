# GHAR runner image

Custom GitHub Actions Self-Hosted runner image for CI/CD workflows, built on the official
GitHub Actions runner image (`ghcr.io/actions/actions-runner`).

## Packages

| Package                                | Version     | Version CLI                |
| -------------------------------------- | ----------- | -------------------------- |
| **Ubuntu (Base OS)**                   | `24.04 LTS` | `cat /etc/os-release`      |
| **GitHub Actions Runner**              | `2.338.2`   | `/home/runner/run.sh --version` |
| **Golang**                             | `1.27.3`    | `go version`               |
| **sqlc**                               | `1.30.0`    | `sqlc version`             |
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

## Tool cache

`RUNNER_TOOL_CACHE=/opt/hostedtoolcache` holds the versions Cognyx CI pins, so
`actions/setup-go`, `setup-node` and `setup-python` find them without a download:

| Tool   | Version   |
| ------ | --------- |
| Go     | `1.27.3`  |
| Node   | `24.22.1` |
| Python | `3.13.15` |

When CI bumps one of these (`go-version`, `node-version`, `python-version` in
`Cognyx/cognyx`), bump the matching `ARG` in the Dockerfile too. Until then the setup
action downloads the new version on each job, as before.

## Rebuilds

The image builds on a push to `main` that changes the Dockerfile or the workflow, and
every Monday at 05:17 UTC without the layer cache, so `apt-get upgrade` picks up OS
security fixes. Run the workflow by hand for an urgent rebuild.

Every build runs a smoke test (Go, Node, Python, sqlc, Docker Compose and the tool cache)
before anything is pushed. A failed test pushes nothing, and runners keep the last `latest`.
To roll back, pin a `main-<sha>-<epoch>` tag in the runner set.

## Notes

- Docker-in-Docker is provided by a sidecar container (infra), not this image.
- The runner `PATH` env file lives at `/home/runner/.env`.
- The image is pushed to `eu.gcr.io/cognyx-471812/ghar-image:latest` (plus `{{branch}}-{{sha}}-{{date}}`).
