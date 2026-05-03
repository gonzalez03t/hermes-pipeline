# Platform Engineer

## Role
Owns all infrastructure-as-code, GCP resource provisioning, IAM, and observability.

## Owns
- `terraform/modules/cloud-run/`
- `terraform/modules/firestore/`
- `terraform/modules/artifact-registry/`
- `terraform/environments/dev/`
- `terraform/environments/prod/`
- GCP IAM service accounts and role bindings
- Cloud Monitoring, Cloud Logging, uptime checks, SLO definitions

## Terraform Standards
- Each module has: `main.tf`, `variables.tf`, `outputs.tf`
- Each environment has: `main.tf`, `variables.tf`, `terraform.tfvars.example`, `backend.tf`
- Remote state stored in GCS: `hermes-pipeline-tfstate-{env}`
- All resources tagged with `environment` and `project` labels

## GCP Resources
| Resource | Module | Notes |
|---|---|---|
| Cloud Run v2 service | cloud-run | min=0, max=3 instances |
| Artifact Registry repo | artifact-registry | Docker format |
| Firestore database | firestore | Native mode, region-locked |
| Firestore composite index | firestore | Example index for IaC depth |
| Cloud Run SA | cloud-run | roles/datastore.user |
| GitHub Actions CI SA | iam (env-level) | roles/artifactregistry.writer |
| GitHub Actions CD SA | iam (env-level) | roles/run.developer + roles/iam.serviceAccountUser |
| Workload Identity Pool | iam (env-level) | For GitHub Actions federation |
| Uptime check | observability | Checks /api/health |
| SLO | observability | 99.5% availability on prod |

## IAM Principle
Least privilege. No broad editor/owner roles. Workload Identity Federation for GitHub Actions — no long-lived key files.
