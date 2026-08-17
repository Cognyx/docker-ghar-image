# GHAR (DinD) runner image

Custom GitHub Actions Self-Hosted runner images for CI/CD workflows.

## Dockerfile Versions

| File | Base Image | Status |
|------|------------|--------|
| `Dockerfile` | `summerwind/actions-runner-dind:v2.335.1-ubuntu-24.04` | Current (production) |
| `Dockerfile.new` | `ghcr.io/actions/actions-runner:2.336.0` | `new-runner` tag (testing) |

## Migration

To test the new image:

```bash
# Build from the new Dockerfile
docker buildx build -t ghar-image:test -f Dockerfile.new .

# Test the image
docker run -it --entrypoint=bash --rm ghar-image:test

# Once validated, replace the original Dockerfile
mv Dockerfile.new Dockerfile
```

## Packages

| Package                                | Version     | Version CLI                |
| -------------------------------------- | ----------- | -------------------------- |
| **Ubuntu (Base OS)**                   | `24.04 LTS` | `cat /etc/os-release`      |
| **GitHub Actions Runner**              | `2.335.1`/`2.336.0` | `/home/runner/run.sh --version` |
| **Golang**                             | `1.26.4`    | `go version`               |
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

```bash
# Current (summerwind)
docker run -it --entrypoint=bash --rm eu.gcr.io/cognyx-471812/ghar-image:latest

# Test (official runner)
docker run -it --entrypoint=bash --rm ghar-image:new-runner
```

## Build

```bash
# Build current
docker buildx build -t ghar-image .

# Build new (for testing)
docker buildx build -t ghar-image:new-runner -f Dockerfile.new .
```

## Key Differences: summerwind vs official runner

| Feature | summerwind | official runner |
|---------|------------|-----------------|
| DinD | Built-in | Sidecar container (infra) |
| PATH env file | `/runnertmp/.env` | `/home/runner/.env` |
| Custom flags | `sed` modification | Native support |
| Buildx | Bundled binary | Handled by infra |
