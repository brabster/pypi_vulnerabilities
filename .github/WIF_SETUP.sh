#!/bin/bash
set -euo pipefail

# Based on https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions
# Setting up a Workload Identity Federation for GitHub action.
# Assumes $DBT_PROJECT is set to the project you want the pool/provider in

export WIF_PROJECT=${DBT_PROJECT}
export WIF_PROJECT_NUMBER=$(gcloud projects describe "${WIF_PROJECT}" --format="value(projectNumber)")
export WIF_POOL=dbt-pool
export WIF_PROVIDER=dbt-provider
export WIF_GITHUB_REPO=brabster/pypi_vulnerabilities
export WIF_SERVICE_ACCOUNT=pypi-vulnerabilities

gcloud services enable iamcredentials.googleapis.com --project "${DBT_PROJECT}"

gcloud iam service-accounts create "${WIF_SERVICE_ACCOUNT}" \
    --project="${DBT_PROJECT}" \
    --description="DBT service account" \
    --display-name="${WIF_SERVICE_ACCOUNT}"

gcloud iam workload-identity-pools create "${WIF_POOL}" \
  --project="${WIF_PROJECT}" \
  --location="global" \
  --display-name="DBT Pool"

gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER}" \
  --project="${WIF_PROJECT}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL}" \
  --display-name="DBT provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"

WIF_POOL_PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" --location=global --project "${WIF_PROJECT}" --workload-identity-pool "${WIF_POOL}" --format="value(name)")
WIF_POOL_ID=$(gcloud iam workload-identity-pools describe "${WIF_POOL}" --location=global --project "${WIF_PROJECT}" --format="value(name)")

gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WIF_POOL_ID}/attribute.repository/${WIF_GITHUB_REPO}"

gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="serviceAccount:${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding "${DBT_PROJECT}" \
  --role="roles/bigquery.admin" \
  --member="serviceAccount:${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com"

echo "GitHub Secret: GCP_WORKLOAD_IDENTITY_PROVIDER"
gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" --location=global --project "${DBT_PROJECT}" --workload-identity-pool "${WIF_POOL}" --format="value(name)"

echo "GitHub Secret: GCP_SERVICE_ACCOUNT"
echo "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com"