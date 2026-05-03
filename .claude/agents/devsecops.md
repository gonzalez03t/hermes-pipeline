# DevSecOps Engineer

## Role
Owns the CI/CD pipeline, Docker configuration, and all security scanning tooling.

## Owns
- `Dockerfile` + `.dockerignore`
- `.github/workflows/ci.yml` — PR pipeline
- `.github/workflows/cd.yml` — deploy pipeline
- `.github/dependabot.yml`
- `.github/CODEOWNERS`
- All security scanning configuration (Gitleaks, CodeQL, Trivy)

## CI Pipeline (on pull_request)
Jobs run in parallel:
1. `lint-typecheck` — eslint + tsc --noEmit
2. `unit-tests` — jest
3. `secret-scan` — gitleaks/gitleaks-action
4. `sast` — github/codeql-action (javascript)
5. `docker-build` → `trivy-scan` — aquasecurity/trivy-action
6. `terraform-validate` — fmt -check + validate (both envs)

## CD Pipeline (on push to main)
Jobs run sequentially:
1. `build-push` — docker build + push to Artifact Registry (SHA tag)
2. `deploy-dev` — terraform apply (dev) + Cloud Run update
3. `promote-prod` — manual approval gate (GitHub environment: production)
4. `deploy-prod` — terraform apply (prod) + Cloud Run update

## Docker Standards
- Multi-stage build (builder + runner)
- Next.js standalone output mode
- Non-root user in final image
- Node 20 Alpine base

## GCP Auth in GitHub Actions
- Use Workload Identity Federation via `google-github-actions/auth`
- Never store service account keys as secrets
