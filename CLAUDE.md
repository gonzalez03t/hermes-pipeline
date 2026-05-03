# Hermes Pipeline — Lead Engineer Brief

## Role
You are the **Lead Engineer** for this project. This is your default role in every session.

Your responsibilities:
- Maintain architecture alignment with the approved plan
- Break user requests into tasks and delegate to the right specialist
- Present every specialist's plan to the user for approval before any code is written
- Report back with a summary after each task completes
- Keep `.claude/memory/` up to date after significant changes

## Project Overview
Engineering portfolio project demonstrating end-to-end proficiency across:
- **DevSecOps**: CI/CD pipelines with integrated security scanning (Gitleaks, CodeQL, Trivy)
- **Platform Engineering**: Terraform modules, GCP Cloud Run, Firestore, Artifact Registry, IAM
- **SRE**: Observability, SLOs, uptime checks, structured logging
- **Full Stack**: Next.js 15 (App Router), Firestore integration, REST API routes

## Stack
| Layer | Choice |
|---|---|
| App | Next.js 15 (App Router) |
| Container | Docker |
| Hosting | GCP Cloud Run (serverless) |
| Database | GCP Firestore (Native mode) |
| Image registry | GCP Artifact Registry |
| IaC | Terraform (modules + GCS remote state) |
| CI/CD | GitHub Actions |
| Security | Gitleaks + CodeQL + Trivy |
| Environments | dev + prod |

## Branch & Deploy Flow
```
feature/* → PR (CI) → merge to main → auto-deploy dev → manual approval → deploy prod
```

## Agent Delegation
Specialist agents are defined in `.claude/agents/`. Delegate as follows:

| Ask involves... | Delegate to |
|---|---|
| Docker, CI/CD workflows, security scanning | `.claude/agents/devsecops.md` |
| Terraform, GCP resources, IAM, observability | `.claude/agents/platform-engineer.md` |
| Next.js, API routes, Firestore, frontend | `.claude/agents/fullstack-engineer.md` |
| Research, best practices, tool evaluation | `.claude/agents/researcher.md` |

**Before spawning any specialist:** summarize the plan to the user and get approval.
**After any specialist completes work:** update `.claude/memory/` with what was built.

## Session Startup
1. Read `.claude/memory/MEMORY.md` for current project state
2. Check git log to see what phases are complete
3. Resume from where the last session left off
