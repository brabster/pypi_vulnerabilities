# PRD Implementation TODO — Repartition daily_package_downloads

Goal: Partition `daily_package_downloads` by `download_date` (daily) and cluster by `package`, with zero data loss and minimal/no downtime for consumers.

## Prep & Analysis

- [x] Confirm current table metadata in BigQuery (is it unpartitioned/unclustered?). It is unpartitioned and unclustered.
  - [x] Inspect `pypi-vulns.published_us.daily_package_downloads` schema and size. ~200GB, schema matches dbt model `models/internal/pypi/daily_package_downloads.sql`.
  - [x] Identify consumers (queries/dashboards) that directly reference this table. None, only downstream models.
- [x] Baseline perf/cost for representative queries (bytes billed, runtime) before change.

## Design

- [ ] Partitioning: `partition_by: {field: download_date, data_type: date}`.
- [ ] Clustering: `cluster_by: ['package']`.
- [ ] Incremental strategy: prefer BigQuery `insert_overwrite` by partitions for efficient refresh.
- [ ] Cutover approach: build a new table (v2), validate, and perform atomic table renames to minimize downtime.
  - Rationale: BigQuery cannot alter a non‑partitioned table to partitioned; requires create‑new and swap.

## dbt Changes

- [ ] Create a v2 model `models/internal/pypi/daily_package_downloads_v2.sql` with:
  - [ ] `config(materialized='incremental', partition_by=..., cluster_by=..., incremental_strategy='insert_overwrite', unique_key=['download_date','package','package_version','installer'], on_schema_change='fail')`.
  - [ ] Same SQL body as current `daily_package_downloads.sql` but remove manual `latest_partition_date` guard if using `insert_overwrite`.
- [ ] Option A (preferred): keep original model unchanged; manage cutover via SQL renames in a controlled step.
- [ ] Option B: set `alias='daily_package_downloads_v2'` explicitly if needed to avoid name collisions.

## Backfill & Build

- [ ] In CI or locally, run dbt to build v2 model for the full desired history window.
  - [ ] Ensure `DBT_PYPI_EARLIEST_DOWNLOAD_DATE` is set appropriately for coverage.
  - [ ] Monitor scan bytes; adjust batching if necessary.
- [ ] Verify v2 table is partitioned and clustered as configured.

## Validation

- [ ] Row‑count parity checks between old and v2 for matched date ranges.
- [ ] Aggregate parity: sum downloads per day/package; ensure equality.
- [ ] Spot‑check metrics derived downstream (e.g., `vulnerable_downloads_by_package`).
- [ ] Compare query performance/cost on representative filters (by date, package).

## Cutover (Minimal Downtime)

- [ ] Acquire short change window (seconds) and communicate to stakeholders.
- [ ] Freeze upstream writes to original table (ensure no concurrent dbt job writing).
- [ ] Atomic rename in BigQuery (within same dataset):
  - [ ] `ALTER TABLE daily_package_downloads RENAME TO daily_package_downloads_backup_<timestamp>`
  - [ ] `ALTER TABLE daily_package_downloads_v2 RENAME TO daily_package_downloads`
- [ ] Resume normal operations.

## Post‑Cutover

- [ ] Re‑run dbt build to ensure dependencies/lineage intact and no schema drift.
- [ ] Monitor job metrics and query costs for 24–48h.
- [ ] Update or remove `daily_package_downloads_backup_*` after retention window.

## CI/CD Updates

- [ ] Add optional job to create/build v2 model before cutover.
- [ ] Add validation step (parity checks) as a CI job gate prior to rename.
- [ ] Add a one‑off GitHub Action (manual `workflow_dispatch`) to perform the rename with safeguards.

## Tests & Docs

- [ ] Add/adjust tests to reference v2 during validation phase.
- [ ] Update model docs (paired `.yml`) to reflect partitioning and clustering.
- [ ] Add Architecture note on partitioning/clustering rationale.

## Rollback Plan

- [ ] If issues arise, reverse renames:
  - [ ] `ALTER TABLE daily_package_downloads RENAME TO daily_package_downloads_v2_failed_<timestamp>`
  - [ ] `ALTER TABLE daily_package_downloads_backup_<timestamp> RENAME TO daily_package_downloads`
- [ ] Investigate discrepancies; keep v2 for forensics.

## Acceptance Criteria Mapping

- [ ] Optimized structure: Partitioned by `download_date`, clustered by `package` (verified in table metadata).
- [ ] Data integrity: Parity checks pass across history.
- [ ] Incremental updates: v2 incremental runs write into correct partitions.
- [ ] Query compatibility: Existing consumers see identical results post‑swap.
- [ ] Performance improvement: Demonstrated lower bytes processed on filtered queries.
- [ ] Cost reduction: Observed cost decrease in billing models/dashboards.

