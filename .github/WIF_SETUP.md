Based on https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions

Setting up a Workload Identity Federation for GitHub action.
Assumes $DBT_PROJECT is set to the project you want the pool/provider in.

# Setup WIF in-project

Unsure whether setting up a WIF pool/provider for each project is the best way, but it seems like the least risky.

```console
export WIF_PROJECT_NUMBER=$(gcloud projects describe "${DBT_PROJECT}" --format="value(projectNumber)")
export WIF_POOL=dbt-pool
export WIF_PROVIDER=dbt-provider
export WIF_GITHUB_REPO=brabster/pypi-vulnerabilities
export WIF_SERVICE_ACCOUNT=pypi-vulnerabilities
```

```console
gcloud services enable iamcredentials.googleapis.com --project "${DBT_PROJECT}"
```

```console
gcloud iam workload-identity-pools create "${WIF_POOL}" \
  --project="${DBT_PROJECT}" \
  --location="global" \
  --display-name="DBT Pool"
```

```console
gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER}" \
  --project="${DBT_PROJECT}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL}" \
  --display-name="DBT provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

```console
gcloud iam service-accounts create "${WIF_SERVICE_ACCOUNT}" \
    --project="${DBT_PROJECT}" \
    --description="DBT service account" \
    --display-name="${WIF_SERVICE_ACCOUNT}"
```

```console
gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${WIF_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL}/attribute.repository/${WIF_GITHUB_REPO}"
```

```console
gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" 
```

# Recover Secrets for GitHub

```console
echo "GitHub Secret: GCP_WORKLOAD_IDENTITY_PROVIDER"
gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" --location=global --project "${DBT_PROJECT}" --workload-identity-pool "${WIF_POOL}" --format="value(name)"
```

```console
echo "GitHub Secret: GCP_SERVICE_ACCOUNT"
echo "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com"
```

