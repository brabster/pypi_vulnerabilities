# Architecture Overview

This project analyzes PyPI download activity to quantify downloads of known‑vulnerable package versions by date, package, and installer, and publishes derivative metrics and documentation.

## Purpose

- Derive insights from public datasets about vulnerable downloads on PyPI.
- Produce consumer‑friendly BigQuery tables and dbt documentation.
- Keep Safety DB vulnerability history available in BigQuery for joins and reproducibility.

## System Overview

- Data sources
  - PyPI public dataset: `bigquery-public-data.pypi.file_downloads`.
  - PyUp Safety DB (public GitHub repo) for vulnerability specs (per package/CVE).
- Ingestion & modeling
  - Lightweight Python ETL loads Safety DB commit history into a partitioned BigQuery table.
  - dbt (BigQuery adapter) stages downloads, normalizes vulnerability “effective windows,” matches semver specs, joins data, and publishes metrics.
- Orchestration & delivery
  - GitHub Actions provisions the environment, ensures datasets, loads Safety DB, builds/tests dbt models, cleans up orphans, and publishes dbt docs to GitHub Pages.

## High‑Level Data Flow

1. Fetch Safety DB commits and raw JSON, convert to JSONL records with commit metadata.
2. Load/refresh partition(s) in `…_internal.safety_db_history` (partitioned by commit date).
3. Stage PyPI downloads and aggregate daily counts by `download_date, package, package_version, installer`.
4. Normalize Safety DB entries to per‑package/CVE rows with effective window `[commit_date, until_date)`.
5. Match each download’s `package_version` against vulnerability specs (semver UDFs) within the window.
6. Aggregate to produce flags/arrays and build a cube to power published metrics.
7. Expose consumer‑facing metric tables and publish docs.

## Components

### dbt Project

- Core config: `dbt_project.yml:1` — model/test/macro paths; labels; schemas (`internal`, `billing`); colors; materialization settings.
- Profile: `profiles.yml:1` — BigQuery profile sourced from env vars (`DBT_PROJECT`, `DBT_LOCATION`, `DBT_DATASET`, etc.).
- Packages: `packages.yml:1` — `dbt_utils` and `dbt_materialized_udf`.

### Safety DB ETL (Python)

- Fetch/transform:
  - `etl/safety_db/github.py:1` — lists commits for `pyupio/safety-db` JSON file, fetches raw content, converts to JSONL with commit metadata.
- BigQuery helpers:
  - `etl/safety_db/bigquery.py:1` — client creation, dataset ensure, partition discovery, partitioned table creation, JSONL load.
- Orchestrator:
  - `etl/safety_db/load_missing_partitions.py:1` — CLI entrypoint to load missing commit‑date partitions since a given timestamp.
- Schema:
  - `etl/safety_db/safety_schema.json:1` — BigQuery table schema (nested/repeated fields for vulnerabilities).

### Macros (dataset mgmt & cleanup)

- Ensure datasets: `macros/ensure_datasets.sql:1` — creates published, `internal`, and `billing` datasets with labels and optional public grants.
- Dataset helper: `macros/dataset.sql:1` — generic dataset creation/grant logic.
- Cleanup: `macros/cleanup.sql:1` — generates SQL to drop orphaned UDFs/views/tables in in‑scope schemas.

### Sources

- PyPI: `models/sources/public_pypi.yml:1` — `bigquery-public-data.pypi.file_downloads`.
- Safety DB: `models/sources/safety_db.yml:1` — internal `safety_db_history` table populated by ETL.
- Billing (optional): `models/sources/gcp_billing.yml:1` — cost/usage reporting.

### Internal Models & UDFs

- Downloads staging/aggregation:
  - `models/internal/pypi/file_downloads.sql:1` — select/derive core fields including `download_date`, `package`, `package_version`, `installer`.
  - `models/internal/pypi/daily_package_downloads.sql:1` — incremental aggregation keyed by date/package/version/installer; earliest date via `DBT_PYPI_EARLIEST_DOWNLOAD_DATE`.
- Safety DB normalization:
  - `models/internal/safety_db/safety_vulnerabilities.sql:1` — flatten vulnerabilities; derive `commit_date`, `until_date` (LEAD/backfill), `fix_was_available`, `is_first_commit`.
- Semver/Spec UDFs (core matching logic):
  - Parsing/comparable building: `semver_to_comparable`, `semver_part_to_comparable`, `semver_index_to_comparable`, `extract_release`, `extract_prerelease[_prefix|_suffix]`, `safe_extract_semver_part`, `lpad_semver_part` (see `models/internal/udfs/*.sql`).
  - Spec parsing/matching: `extract_op`, `extract_version`, `spec_has_upper_bound`, `multi_spec_has_at_least_one_upper_bound`, `matches_spec`, `matches_maybe_compound_spec`, `matches_multi_spec` (see `models/published/udfs/*.sql` and `models/internal/udfs/*.sql`).
- Join & cube:
  - `models/internal/downloads_and_vulnerabilities.sql:1` — left join downloads to safety windows; compute `was_known_vulnerable_when_downloaded` using `matches_multi_spec`.
  - `models/internal/vulnerabilities_by_download.sql:1` — aggregate CVEs per record; emit `vulnerabilities` array and `was_vulnerable` flag.
  - `models/internal/download_vulnerability_cube.sql:1` — CUBE over `download_date, package, installer, was_vulnerable` to enable flexible metrics.

### Published Metrics

- Overall: `models/published/metrics/vulnerable_downloads_overall.sql:1` — daily proportion of vulnerable downloads overall.
- By package: `models/published/metrics/vulnerable_downloads_by_package.sql:1` — per‑package proportions.
- By installer: `models/published/metrics/vulnerable_downloads_by_installer.sql:1` — per‑installer proportions.
- By CVE: `models/published/metrics/vulnerable_downloads_by_cve.sql:1` — daily counts by CVE.

### Billing & Observability

- Cost/usage aggregation: `models/billing/daily_billing.sql:1`.
- Looker Studio query stats: `models/billing/looker_studio_billing.sql:1`.

## Orchestration & CI/CD

- Workflow: `.github/workflows/deploy.yml:1`
  - Setup Python/dbt venv: `.github/actions/setup_dbt/action.yml:1`.
  - GCP auth via WIF; ensure datasets: `dbt run-operation ensure_datasets`.
  - Load Safety DB partitions: `python etl/safety_db/load_missing_partitions.py`.
  - Build models & docs: `.github/actions/dbt_build/action.yml:1`.
  - Cleanup orphans: `dbt run-operation cleanup`.
  - Contract tests: `.github/actions/dbt_contract_test/action.yml:1`.
  - Publish dbt docs to GitHub Pages.
- Environments/vars
  - `.envs/prod/.env:1` sets `DBT_PROJECT`, `DBT_DATASET` (`published_us`), `DBT_LOCATION` (`US`).
  - GitHub environment variables: `DBT_PYPI_EARLIEST_DOWNLOAD_DATE`, `DBT_MAX_GIGABYTES_BILLED` to cap scan costs.

## Modeling Conventions

- Layering
  - Sources: `models/sources/*`.
  - Internal: `models/internal/**` (staging, UDFs, joins, cubes).
  - Published: `models/published/**` (consumer‑facing models/UDFs).
  - Billing: `models/billing/**`.
- Materializations
  - Incremental: `daily_package_downloads` with `unique_key` set for idempotence and efficient refresh.
  - UDFs: materialized via `dbt_materialized_udf`.
  - Tables/views: for aggregates and cubes as appropriate.
- Governance
  - Datasets labeled and optionally public via macros; `internal` vs published schemas separate stability concerns.

## Testing & Documentation

- UDF tests: `tests/udfs/*.sql` validate semver parsing and spec matching.
- Contracts/sanity checks: e.g., `tests/contracts/docs/assert_top_ten_packages_by_vulnerable_downloads.sql:1`.
- Example data for UDF tests: `test_models/udf_tests/*.sql`.
- Docs
  - dbt docs overview: `models/overview.md:1`.
  - Project docs and examples: `docs/README.md:1`.

## Security & Compliance

- Local dependency scanning with `safety` (note non‑commercial license constraints); policy overrides: `.safety-policy.yml:1`.
- Data is derived from public sources; no sensitive user data is ingested.

## Extensibility

- New metrics/views: add a model under `models/internal` or `models/published`, pair with a `.yml` for docs/tests, and wire into lineage.
- Additional vulnerability sources: write ETL to a normalized, partitioned table; register a source and adapt normalization to match `safety_vulnerabilities` shape.
- Cost/performance: tune partitioning/clustering in model configs; adjust `DBT_MAX_GIGABYTES_BILLED` and earliest date windows.

