# Project Requirements Document (PRD): BigQuery Table Optimization for `daily_package_downloads`

## Context for AI Agent

This document outlines the requirements for optimizing the `daily_package_downloads` table within the `pypi-vulns.published_us` dataset in BigQuery. The primary goal is to enhance query performance and reduce costs by implementing partitioning and clustering. The existing table is updated incrementally on a weekly basis. The implementation should ensure zero data loss and minimal to no downtime for consuming applications and reports.

The current table schema is:
- `download_date` (DATE, NULLABLE)
- `package` (STRING, NULLABLE)
- `package_version` (STRING, NULLABLE)
- `installer` (STRING, NULLABLE)
- `download_count` (INTEGER, NULLABLE)

The `daily_package_downloads` table is managed via `dbt`. The solution should consider how these changes will be integrated into the existing `dbt` codebase, specifically how the model definition for `daily_package_downloads` will be updated or replaced to reflect the new optimized structure.

## Project Goal

To optimize the `daily_package_downloads` table in BigQuery by implementing partitioning and clustering, thereby improving query performance and reducing query costs, without causing data loss or service interruption.

## Desired Outcome

The `daily_package_downloads` table will be restructured to leverage BigQuery's partitioning and clustering features. Specifically, it will be partitioned by `download_date` (daily partitioning) and clustered by `package`. All existing and future data will reside in this optimized structure.

## Acceptance Criteria

### Functional Requirements

1.  **Optimized Table Structure:** The `daily_package_downloads` table (or its logical equivalent accessible via the original name) must be partitioned by the `download_date` column (daily partitioning) and clustered by the `package` column.
2.  **Data Integrity:** All historical data from the original `daily_package_downloads` table must be present and accurate in the new optimized structure.
3.  **Incremental Updates:** The weekly incremental data load process for `daily_package_downloads` must successfully write new data into the optimized table structure, respecting the partitioning and clustering definitions.
4.  **Query Compatibility:** All existing queries, dashboards, and applications that reference `pypi-vulns.published_us.daily_package_downloads` must continue to function correctly and return the same data as before the optimization.
5.  **Performance Improvement:** Queries filtering or grouping by `download_date` and/or `package` should demonstrate a measurable improvement in execution time and/or a reduction in bytes processed.
6.  **Cost Reduction:** The overall BigQuery query costs associated with `daily_package_downloads` should decrease due to more efficient data scanning.

### Non-Functional Requirements

1.  **Zero Data Loss:** No data from the `daily_package_downloads` table, historical or incremental, shall be lost during the optimization process.
2.  **Minimal Downtime:** The transition to the optimized table structure must occur with minimal to no downtime for data consumers. Queries against the table should remain available throughout the process.
3.  **Idempotency:** The solution should be designed such that it can be re-run or recovered from failure points without adverse effects on data integrity.
4.  **Observability:** The process should include mechanisms to monitor the data migration and the performance of the new table.

### dbt Specific Requirements

1.  **dbt Model Update:** The `dbt` model responsible for `daily_package_downloads` must be updated to reflect the new partitioning and clustering configurations.
2.  **Incremental Strategy:** If `daily_package_downloads` is an incremental `dbt` model, the incremental strategy should be compatible with the new partitioned and clustered structure (e.g., using `merge` or `insert_overwrite` with appropriate `unique_key` or `partition_by` settings).
3.  **Codebase Cleanliness:** The `dbt` codebase should be clean and maintainable after the change, with no redundant or deprecated model definitions left active.
