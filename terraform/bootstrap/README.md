# Terraform Bootstrap

One-time manual setup that creates the GCP project and the GCS buckets used for remote Terraform state in all other environments. State for this module is stored locally.

## Prerequisites

- `gcloud` CLI installed and authenticated
- A GCP billing account ID

## Steps

1. Authenticate with application-default credentials:

   ```bash
   gcloud auth application-default login
   ```

2. Initialize Terraform (local state, no backend config needed):

   ```bash
   terraform init
   ```

3. Apply, supplying your billing account ID:

   ```bash
   terraform apply -var="billing_account_id=YOUR_BILLING_ID"
   ```

After a successful apply the two state buckets (`hermes-pipeline-tfstate-dev` and `hermes-pipeline-tfstate-prod`) will exist and the environment workspaces can be initialized.
