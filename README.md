# Hermes Pipeline

A production-grade engineering portfolio demonstrating end-to-end DevSecOps, platform engineering, SRE, and full-stack development using modern cloud-native tooling.

---

## Overview

Hermes Pipeline is a reference implementation built to showcase real-world engineering practices across four domains:

| Domain | What's demonstrated |
|---|---|
| **DevSecOps** | CI/CD pipelines with integrated security scanning, secrets detection, SAST, and container CVE scanning |
| **Platform Engineering** | Infrastructure-as-code with Terraform, GCP Cloud Run, Firestore, Artifact Registry, and least-privilege IAM |
| **SRE** | Structured logging, Cloud Monitoring metrics, uptime checks, and SLO definitions |
| **Full Stack** | Next.js 15 (App Router) with server-side Firestore integration and REST API routes |

---

## Architecture

```
                        ┌─────────────────────────────────────-┐
                        │           GitHub Actions             │
                        │                                      │
  feature/* ──PR──►  CI │  lint · tests · gitleaks · codeql    │
                        │  docker build · trivy · tf validate  │
                        └─────────────────┬───────────────────-┘
                                          │ merge to main
                        ┌─────────────────▼──────────────────-─┐
                        │           GitHub Actions             │
                        │                                      │
                        │  build + push image (SHA tag)        │
                        │         │                            │
                        │  terraform apply ──► Cloud Run (dev) │
                        │         │                            │
                        │  manual approval gate                │
                        │         │                            │
                        │  terraform apply ──► Cloud Run (prod)│
                        └────────────────────────────────────-─┘

GCP Infrastructure (per environment):
┌──────────────────────────────────────────────────┐
│                                                  │
│  Artifact Registry ──► Cloud Run ──► Firestore   │
│                            │                     │
│                     Cloud Monitoring             │
│                     Cloud Logging                │
│                     Uptime Check                 │
└──────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | [Next.js 15](https://nextjs.org) (App Router, TypeScript) |
| Container | Docker (multi-stage, Node 20 Alpine, non-root user) |
| Hosting | GCP Cloud Run (serverless, scales to zero) |
| Database | GCP Firestore (Native mode) |
| Image Registry | GCP Artifact Registry |
| Infrastructure | Terraform (modular, remote state in GCS) |
| CI/CD | GitHub Actions |
| Secret Scanning | [Gitleaks](https://github.com/gitleaks/gitleaks) |
| SAST | [CodeQL](https://codeql.github.com) |
| Container Scanning | [Trivy](https://github.com/aquasecurity/trivy) |
| Auth (GCP) | Workload Identity Federation (no long-lived keys) |
| Environments | `dev` · `prod` |

---

## Repository Structure

```
hermes-pipeline/
├── .claude/
│   └── agents/                   # Specialist agent definitions
│       ├── lead-engineer.md
│       ├── devsecops.md
│       ├── platform-engineer.md
│       ├── fullstack-engineer.md
│       └── researcher.md
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                # PR pipeline
│   │   └── cd.yml                # Deploy pipeline
│   ├── CODEOWNERS
│   └── dependabot.yml
├── app/                          # Next.js 15 source
│   ├── api/
│   │   ├── health/route.ts       # Health check endpoint
│   │   └── items/route.ts        # Firestore CRUD API
│   ├── page.tsx
│   └── layout.tsx
├── lib/
│   └── firestore.ts              # Firestore client (ADC)
├── terraform/
│   ├── modules/
│   │   ├── artifact-registry/    # Docker image registry
│   │   ├── cloud-run/            # Cloud Run service + IAM
│   │   └── firestore/            # Firestore DB + indexes
│   └── environments/
│       ├── dev/
│       └── prod/
├── Dockerfile
├── .dockerignore
├── next.config.ts
└── CLAUDE.md
```

---

## CI/CD Pipeline

### CI — runs on every Pull Request

Jobs execute in parallel:

```
lint-typecheck   →  ESLint + tsc --noEmit
unit-tests       →  Jest
secret-scan      →  Gitleaks (detects committed secrets)
sast             →  CodeQL (static analysis)
docker-build     →  Build image (not pushed)
  └── trivy-scan →  CVE scan on built image
tf-validate      →  terraform fmt -check + validate (dev + prod)
```

All jobs must pass before a PR can be merged.

### CD — runs on merge to `main`

Jobs execute sequentially:

```
1. build-push    →  docker build + push to Artifact Registry (tagged with git SHA)
2. deploy-dev    →  terraform apply (dev) + Cloud Run deploy (dev)
3. approve       →  manual approval gate (GitHub environment: production)
4. deploy-prod   →  terraform apply (prod) + Cloud Run deploy (prod)
```

---

## Infrastructure

Terraform is organized into reusable modules consumed by each environment.

### Modules

**`terraform/modules/cloud-run/`**
- Cloud Run v2 service (min: 0, max: 3 instances)
- IAM binding for public invocation
- Dedicated service account with `roles/datastore.user`
- Outputs: `service_url`

**`terraform/modules/firestore/`**
- Firestore database (Native mode, region-locked)
- Composite index (demonstrates IaC depth)

**`terraform/modules/artifact-registry/`**
- Docker repository for container images

### Environments

Each environment (`dev`, `prod`) has isolated GCP resources and its own Terraform state bucket:

| Resource | dev | prod |
|---|---|---|
| State bucket | `hermes-pipeline-tfstate-dev` | `hermes-pipeline-tfstate-prod` |
| Cloud Run service | `hermes-pipeline-dev` | `hermes-pipeline-prod` |
| Firestore database | `hermes-pipeline-dev` | `hermes-pipeline-prod` |

### IAM Design (Least Privilege)

| Identity | Role | Purpose |
|---|---|---|
| Cloud Run service account | `roles/datastore.user` | Read/write Firestore |
| GitHub Actions CI | `roles/artifactregistry.writer` | Push images |
| GitHub Actions CD | `roles/run.developer` + `roles/iam.serviceAccountUser` | Deploy Cloud Run |

**Workload Identity Federation** is used for GitHub Actions → GCP authentication. No long-lived service account keys are stored in GitHub secrets.

---

## Application

The Next.js app is intentionally minimal — the infrastructure and pipeline are the showcase.

### API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/api/health` | GET | Returns `{ status, env }` — used as Cloud Run health check |
| `/api/items` | GET | Lists all items from Firestore |
| `/api/items` | POST | Creates a new item in Firestore |

### Firestore Access

The app uses the [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup) with Application Default Credentials (ADC):

- **Locally**: authenticate with `gcloud auth application-default login`
- **On Cloud Run**: uses the attached service account automatically — no credentials in environment variables

---

## SRE & Observability

| Signal | Implementation |
|---|---|
| Metrics | Cloud Run built-in metrics (request count, latency, instance count) → Cloud Monitoring |
| Logs | Structured JSON logging from Next.js → Cloud Logging |
| Uptime | Cloud Monitoring uptime check on `/api/health` |
| SLO | 99.5% availability defined in Terraform for `hermes-pipeline-prod` |

---

## Local Development

**Prerequisites:** Node.js 20+, Java 21+ (for Firestore emulator), [Firebase CLI](https://firebase.google.com/docs/cli)

```bash
# Install Firebase CLI (once)
npm install -g firebase-tools

# Install dependencies
npm install

# Copy environment template
cp .env.local.example .env.local
```

Run the app locally using two terminals:

**Terminal 1 — Firestore emulator:**
```bash
npm run emulator
```

**Terminal 2 — Next.js dev server:**
```bash
npm run dev
```

| URL | Description |
|---|---|
| `http://localhost:3000` | App |
| `http://localhost:3000/api/health` | Health check |
| `http://localhost:3000/api/items` | Items API |
| `http://localhost:4000` | Firestore emulator UI |

---

## Deployment

Deployments are fully automated via GitHub Actions. To trigger:

1. Create a feature branch: `git checkout -b feature/your-change`
2. Open a Pull Request → CI pipeline runs automatically
3. Merge to `main` → CD pipeline deploys to `dev` automatically
4. Approve the production gate in GitHub Actions → deploys to `prod`

---

## Agent Collaboration

This project is built using a structured multi-agent workflow with Claude Code. Claude acts as **Lead Engineer** by default, delegating to specialists defined in `.claude/agents/`:

| Agent | Domain |
|---|---|
| Lead Engineer | Orchestration, architecture, task breakdown |
| DevSecOps Engineer | Docker, GitHub Actions, security scanning |
| Platform Engineer | Terraform, GCP, IAM, observability |
| Full Stack Engineer | Next.js, API routes, Firestore |
| Researcher | Best practices, tool evaluation |
| UX Designer *(planned)* | UI components, design system |

All specialist plans are presented for approval before any code is written.

---

## License

MIT
