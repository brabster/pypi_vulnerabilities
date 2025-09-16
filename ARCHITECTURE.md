
# Architecture

This document outlines the architecture of the PyPI Vulnerabilities project.

## Overview

This project is a data engineering pipeline that ingests data from various sources, transforms it, and creates a series of data models to analyze PyPI package downloads and security vulnerabilities. The core of the project is a dbt (data build tool) workflow that runs on Google BigQuery.

## Data Sources

The project uses the following data sources:

- **Google BigQuery (Public Data):** The primary data source is the public `the-psf.pypi.downloads` dataset on Google BigQuery, which contains historical data about PyPI package downloads.
- **Safety-DB:** A database of known security vulnerabilities in Python packages. The data is extracted from the `safety-db` GitHub repository.
- **GCP Billing:** Google Cloud Platform billing data is used to monitor the costs associated with the project.

## ETL (Extract, Transform, Load)

The ETL process is handled by a combination of Python scripts and dbt:

- **Python Scripts:** The scripts in the `etl/` directory are responsible for extracting data from the Safety-DB and loading it into BigQuery.
- **dbt:** dbt is used for the "T" (Transform) part of ETL. It transforms the raw data from the sources into a series of well-defined and tested data models.

## Data Modeling

The data modeling is done using dbt. The models are organized into the following directories:

- **`models/sources/`:** This directory contains the dbt source definitions, which declare the raw data tables that the project uses.
- **`models/internal/`:** This directory contains the staging and intermediate data models. These models perform the initial cleaning and transformation of the raw data.
- **`models/internal/udfs/`:** This directory contains a number of user-defined functions (UDFs) for BigQuery. These UDFs are used to parse and compare software versions (semver), which is a critical part of the vulnerability analysis.
- **`models/published/`:** This directory contains the final, user-facing data models. These models combine the download data with the vulnerability data to create a series of metrics, such as `vulnerable_downloads_by_cve` and `vulnerable_downloads_by_package`.
- **`models/billing/`:** This directory contains models for analyzing the project's own costs.

## Testing

The project has a comprehensive test suite to ensure data quality and the correctness of the transformations. The tests are located in the following directories:

- **`tests/`:** This directory contains dbt tests for data contracts, UDFs, and specific model logic.
- **`test_models/`:** This directory contains dbt models that are used for testing, particularly for the semver UDFs.

## Deployment

The project is deployed using GitHub Actions. The deployment workflow is defined in the `.github/workflows/deploy.yml` file. The workflow uses a series of custom GitHub Actions (located in the `.github/actions/` directory) to set up dbt and run the dbt commands.
