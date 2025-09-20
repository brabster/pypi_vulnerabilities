# PyPI Vulnerabilities Analysis

PyPI Vulnerabilities is a dbt-based BigQuery data pipeline project that analyzes PyPI package downloads and maps them against known security vulnerabilities from the Safety DB.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Setup
- **CRITICAL**: Requires Python 3.11 (per dbt compatibility - https://docs.getdbt.com/faqs/Core/install-python-compatibility)
- Python 3.12 works but may have compatibility warnings
- Set environment variable `PIP_REQUIRE_VIRTUALENV=true` to prevent accidental system installs

### Bootstrap and Build Process
**NEVER CANCEL builds or long-running commands. Set timeouts appropriately.**

1. **Initial Setup** - takes ~2 minutes. NEVER CANCEL, set timeout to 5+ minutes:
   ```bash
   cd /path/to/repository
   python3.11 -m venv venv  # or use existing .dev_scripts/init_and_update.sh
   source venv/bin/activate
   pip install --upgrade pip setuptools
   pip install --upgrade safety  # vulnerability scanner - NOT free for commercial use
   pip install -U -r requirements.txt  # installs dbt-bigquery>=1.7.0
   ```

2. **Install dbt Dependencies** - takes ~30 seconds, requires network access:
   ```bash
   dbt deps  # downloads packages from hub.getdbt.com
   ```
   - **FALLBACK**: If `dbt deps` fails due to network restrictions, the project can still function but some packages may be missing

3. **Vulnerability Check** - takes ~5 seconds with network:
   ```bash
   safety check  # may fail in restricted network environments
   ```

### VSCode Integration
- A VSCode task automatically runs `.dev_scripts/init_and_update.sh` on folder open
- Task is configured in `.vscode/tasks.json`

## Working with BigQuery

### Prerequisites
- GCP Project with BigQuery enabled
- Environment variables configured (see `.env_template`):
  ```bash
  export DBT_DATASET=sandbox_your_name
  export DBT_LOCATION=US
  export DBT_PROJECT=some-project-id  # MUST be project ID, not name!
  export DBT_PYPI_EARLIEST_DOWNLOAD_DATE=2024-01-01
  ```

### Authentication
- Requires Google Cloud credentials: `gcloud auth application-default login`
- Verify with: `dbt debug` (will show settings/versions if working)

### dbt Commands
**NEVER CANCEL dbt operations. They may take significant time.**

- **Parse**: `dbt parse --no-version-check` - takes ~5 seconds
- **List models**: `dbt list` - shows available models, tests, etc.
- **List dependencies**: `dbt list --models +model_name+` - shows model lineage
- **Build**: `dbt build --exclude contracts` - **takes 10-30 minutes. NEVER CANCEL. Set timeout to 45+ minutes**
- **Test**: `dbt test` - takes 5-15 minutes. NEVER CANCEL. Set timeout to 20+ minutes  
- **Generate docs**: `dbt docs generate` - takes ~30 seconds
- **Serve docs**: `dbt docs serve` - starts local web server

### dbt Operations (macros)
- **Dataset creation**: `dbt run-operation ensure_datasets` - creates BigQuery datasets
- **Cleanup**: `dbt run-operation cleanup --args '{dry_run: True}'` - dry run cleanup of orphaned objects
- **Cleanup execute**: `dbt run-operation cleanup --args '{dry_run: False}'` - actual cleanup execution

## ETL Pipeline

### Safety DB Loading
Load missing partitions from Safety DB (PyUpio vulnerability database):
```bash
python etl/safety_db/load_missing_partitions.py \
  --project_id ${DBT_PROJECT} \
  --location ${DBT_LOCATION} \
  --dataset ${DBT_DATASET}_internal
```

### Python ETL Scripts
- All Python files in `etl/` directory compile successfully
- Main script: `etl/safety_db/load_missing_partitions.py`
- Support modules: `etl/safety_db/bigquery.py`, `etl/safety_db/github.py`

## Validation Requirements

**Always run these validation steps after making changes:**

1. **Python Syntax**: `python -m py_compile etl/safety_db/*.py` - all ETL files compile successfully
2. **dbt Version**: `dbt --version` - should show dbt 1.10.11+ with bigquery plugin
3. **dbt Parse**: `dbt parse --no-version-check` (requires env vars)
4. **dbt List**: `dbt list` - shows available models if parsing succeeds
5. **dbt Build**: `dbt build --exclude contracts` (requires BigQuery credentials)
6. **Manual Testing**: 
   - Verify SQL queries can parse
   - Check model dependencies with `dbt list --models +model_name+`
   - Review generated documentation

## Common Issues and Workarounds

### Network Restrictions
- `dbt deps` may fail if `hub.getdbt.com` is blocked
- `safety check` fails if Safety API is unreachable  
- ETL scripts fail if GitHub API is blocked

### Python Version Issues
- dbt officially requires Python 3.11
- Python 3.12 works but may show compatibility warnings
- Use `python3.11 -m venv venv` if available

### BigQuery Connection Issues
- Verify project ID (not project name) in environment variables
- Check `gcloud auth application-default login` status
- Use `dbt debug` to troubleshoot connection

## Project Structure

### Key Directories
- `models/`: dbt SQL models organized by schema (published, internal, billing)
- `models/published/`: Public-facing analytics models
- `models/internal/`: Internal processing models  
- `etl/safety_db/`: Python ETL scripts for vulnerability data
- `macros/`: dbt macros for common operations
- `tests/`: Custom dbt tests
- `.dev_scripts/`: Setup and utility scripts
- `.github/workflows/`: CI/CD pipeline (deploy.yml)

### Build Output
- `target/`: Generated dbt artifacts and documentation
- `logs/`: dbt execution logs
- Public documentation deployed to GitHub Pages

## Common Tasks

### Quick Reference of Key Files
```
├── .dev_scripts/init_and_update.sh    # Main setup script
├── .env_template                      # Environment variables template  
├── .vscode/tasks.json                 # VSCode automation
├── requirements.txt                   # Python dependencies (just dbt-bigquery)
├── dbt_project.yml                    # dbt configuration
├── profiles.yml                       # BigQuery connection settings
├── packages.yml                       # dbt package dependencies
├── models/published/                  # Public analytics models
├── models/internal/                   # Internal processing models  
├── etl/safety_db/                     # Python ETL scripts
├── macros/                           # dbt macros (ensure_datasets, cleanup)
└── .github/workflows/deploy.yml       # CI/CD pipeline
```

### Frequently Used Commands (Copy-Paste Ready)
```bash
# Setup (one time)
python3.11 -m venv venv
source venv/bin/activate
pip install -U -r requirements.txt
dbt deps

# Daily workflow
source venv/bin/activate
dbt --version                          # verify installation
dbt list                              # show available models
dbt parse --no-version-check          # validate syntax
dbt build --exclude contracts         # full build (needs BigQuery)

# Operations
dbt run-operation ensure_datasets      # create datasets
dbt run-operation cleanup --args '{dry_run: True}'  # preview cleanup
python etl/safety_db/load_missing_partitions.py --help  # ETL options
```

## GitHub Actions CI/CD

The project uses `.github/workflows/deploy.yml` for automated deployment:
- **Setup**: ~2 minutes
- **Safety DB Load**: ~5-10 minutes  
- **dbt Build**: **15-45 minutes. NEVER CANCEL**
- **Cleanup**: ~2 minutes
- **Documentation**: ~1 minute

## Measured Timings (CRITICAL FOR TIMEOUTS)

**Based on actual testing - always add 50% buffer to these times for timeouts:**

- Virtual environment setup: ~30 seconds
- `pip install -U -r requirements.txt`: **~90 seconds**
- `dbt deps`: ~30 seconds (when network accessible)
- `safety check`: ~5 seconds (when network accessible)
- Total initial setup: **~2 minutes** (without network issues)

**Network failure scenarios:**
- `dbt deps` fails on `hub.getdbt.com` connectivity issues
- `safety check` fails with "Check your network connection, unable to reach the server"
- ETL scripts fail if GitHub API is unreachable

## Timeout Recommendations

**CRITICAL**: Always set appropriate timeouts to prevent premature cancellation:

- Initial setup: 5+ minutes
- `dbt deps`: 2+ minutes  
- `dbt build`: 45+ minutes
- `dbt test`: 20+ minutes
- Safety DB ETL: 15+ minutes
- GitHub Actions full pipeline: 60+ minutes

**DO NOT** cancel builds or tests early - they may take much longer than expected but should complete successfully.