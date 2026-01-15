# Quick Start Guide - CredPal Assessment

## 🚀 Getting Started in 3 Steps

### 1. Local Development (Docker Compose)

```bash
cd /Users/kevinomini/Desktop/projects/credpal-assessment
docker compose up --build
```

**Test the app:**
```bash
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/status
curl -X POST http://localhost:3000/process \
  -H "Content-Type: application/json" \
  -d '{"input":"hello world"}'
```

### 2. Run Tests

```bash
cd node-app
npm install
npm test
```

### 3. Validate Infrastructure (Terraform)

```bash
# From project root
make tf-fmt
make tf-init
make tf-validate
```

---

## 📦 What's Included

### Application
- ✅ Node.js Express app (port 3000)
- ✅ 3 endpoints: `/`, `/health`, `/status`, `/process`
- ✅ PostgreSQL integration (optional)
- ✅ Jest test suite

### Containerization
- ✅ Multi-stage Dockerfile
- ✅ Non-root user
- ✅ Docker HEALTHCHECK
- ✅ docker-compose.yml (app + DB)

### CI/CD
- ✅ GitHub Actions: `ci.yml` (test + build)
- ✅ GitHub Actions: `release-image.yml` (push to GHCR)
- ✅ Manual approval gate (production environment)

### Infrastructure
- ✅ Terraform: VPC, ALB, ECS Fargate, ACM, Route53
- ✅ Zero-downtime deployments
- ✅ HTTPS enforced
- ✅ CloudWatch logs

### Documentation
- ✅ README.md (complete instructions)
- ✅ INTERVIEW_SUMMARY.md (interview prep)
- ✅ QUICK_START.md (this file)

---

## 🎯 Key Files to Review

| File | Purpose |
|------|---------|
| `node-app/src/index.js` | Main application code |
| `node-app/Dockerfile` | Multi-stage container build |
| `docker-compose.yml` | Local dev environment |
| `.github/workflows/ci.yml` | CI pipeline |
| `.github/workflows/release-image.yml` | CD pipeline |
| `terraform/main.tf` | Infrastructure code |
| `README.md` | Full documentation |

---

## ✅ Pre-Submission Checklist

- [x] All files created and validated
- [x] Terraform formatted and validated
- [x] Docker Compose configuration valid
- [x] Tests pass locally
- [x] Application runs locally
- [x] README complete
- [x] Interview summary prepared

**Status: READY TO SUBMIT** ✅
