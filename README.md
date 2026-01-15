# CredPal DevOps Assessment (Node.js)

This repository contains a production-ready DevOps setup for a simple Node.js service that exposes:

- `GET /health`
- `GET /status`
- `POST /process`

The app runs on **port 3000**.

## Local development

### Run with Docker Compose (app + Postgres)

From the repo root:

```bash
docker compose up --build
```

Then:

- Health: `curl http://localhost:3000/health`
- Status: `curl http://localhost:3000/status`
- Process:

```bash
curl -X POST http://localhost:3000/process \
  -H "Content-Type: application/json" \
  -d '{"input":"hello"}'
```

### Run directly (Node)

```bash
cd node-app
npm install
export PORT=3000
node src/index.js
```

## Containerization

- **Multi-stage Dockerfile**: `node-app/Dockerfile` (deps/test/runtime stages)
- **Non-root runtime**: container runs as `app` user
- **Healthcheck**: Docker `HEALTHCHECK` hits `/health`
- **Compose**: `docker-compose.yml` runs app + Postgres and wires `DATABASE_URL`

## CI/CD (GitHub Actions)

Workflows are in `.github/workflows/`:

- `ci.yml`
  - runs on PRs to `main` and pushes to `main`
  - installs dependencies and runs tests
  - builds the Docker image (no push)
- `release-image.yml`
  - runs on pushes to `main`
  - builds and **pushes** the Docker image to **GitHub Container Registry (GHCR)**
  - includes a `deploy-production` job gated by the GitHub **Environment** named `production`

### Secrets management

- No secrets are committed.
- For AWS deploys, prefer **GitHub OIDC** (no long-lived AWS keys) and store any required values in GitHub Secrets/Environments.

## Infrastructure as Code (Terraform / AWS)

Terraform code lives in `terraform/` and provisions:

- VPC + public subnets (minimal, for assessment)
- Security groups
- Application Load Balancer (HTTP→HTTPS redirect)
- ACM certificate (DNS-validated via Route53)
- ECS Fargate cluster/service with rolling deployments
- CloudWatch logs
- Route53 alias record to the ALB

### Terraform requirements

- Terraform `>= 1.5`
- AWS provider `~> 5.x`
- A Route53 hosted zone for your domain

### Deploy (example)

1) Push this repo to GitHub and ensure the image exists in GHCR (workflow `release-image.yml`).

2) From `terraform/`, apply:

```bash
cd terraform
export TF_PLUGIN_TIMEOUT=5m   # avoids provider plugin startup timeouts
terraform init
terraform apply \
  -var "aws_region=us-east-1" \
  -var "project_name=credpal-assessment" \
  -var "domain_name=app.example.com" \
  -var "hosted_zone_id=Z123456ABCDEFG" \
  -var "container_image=ghcr.io/ORG/REPO/credpal-assessment:latest"
```

3) Visit the output `app_url` and verify:

- `GET https://app.example.com/health`
- `GET https://app.example.com/status`

Or use the provided `Makefile` (runs with `TF_PLUGIN_TIMEOUT=5m` by default):

```bash
make tf-fmt
make tf-init
make tf-validate
make tf-plan EXTRA_ARGS='-var "container_image=ghcr.io/ORG/REPO/credpal-assessment:latest" -var "domain_name=app.example.com" -var "hosted_zone_id=Z123456ABCDEFG"'
# make tf-apply EXTRA_ARGS='...'
```

## Deployment strategy

- **Zero-downtime**: ECS service uses rolling deployments with `min_healthy_percent=50` and `max_percent=200` behind an ALB target group health check (`/health`).
- **Manual approval**: protect the GitHub Environment named `production` to require reviewers before `deploy-production` runs.

## Observability

- Basic structured logging via `console.log`/`console.error`
- CloudWatch logs configured for ECS task

