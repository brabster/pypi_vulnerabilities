Investigating downloads of vulnerable Python packages from PyPI.

Thanks to [Equal Experts](https://equalexperts.com) for supporting this work.

dbt docs automatically published on deployment at https://brabster.github.io/dbt_bigquery_template/

# Pre-Reqs

- Python == 3.11 (see https://docs.getdbt.com/faqs/Core/install-python-compatibility)
- [RECOMMENDED] VSCode to use built-in tasks
- Access to GCP Project enabled for BigQuery
- [RECOMMENDED] set environment variable `PIP_REQUIRE_VIRTUALENV=true`
    - Prevents accidentally installing to your system Python installation (if you have permissions to do so)

# Setup

> Note - on first open, automated tasks that update your local dependency versions will fail because your virtualenv is not yet created. My attempts to automate this process haven't turned out to be reliable, so bootstrapping instructions are provided below. Once set up, automated dependency updates should execute automatically when you open this directory in VSCode.

- open the terminal
    - `Terminal` - `New Terminal`
- create virtualenv and install dependencies
    - Use [VSCode options](https://code.visualstudio.com/docs/python/environments#_creating-environments)
        - `Python - Create Environment`, accept defaults
    - OR manually
        - `python -m venv .venv` (other parts of the project assume venv is in `.venv`, so find/replace if you change that)
        - `source .venv/bin/activate` (`source .venv/Scripts/activate` on Windows/Git-Bash)
        - VSCode command `Python - Select Interpreter`
    - Install dependencies: `pip install -U -r requirements.txt`
- update .env with appropriate values
    - note project ID not project name (manifests as 404 error)
    - `. .env` to update values in use in terminal
- get credentials
    - if no valid credential, then error message says default credentials not found
    - must be application default credential
    - `gcloud auth application-default login`
- `dbt debug` should now succeed and list settings/versions
    - if `dbt` is not found, you may need to activate your venv at the terminal as described earlier

# Timeframe

I'm performing this initial analysis on package downloads performed on a specific date, 2023-11-05. There's a few reasons for that:

- PyPI downloads is a big dataset - days in late 2023 are on the order of 250GB. At $5/TB scanned, that's about a dollar a day to scan one day of the full dataset.
- The Safety public dataset is updated monthly, so I can use a the 2023-10-01 update to be sure that any vulnerabilities I'm considering have been in the public domain and accessible via tools for at least a month.

I can get an idea of what's going on and figure out how to solve the problems that need solving with a relatively small snapshot dataset, so I copy just the columns I need for one day with minimal processing to a new table and work from that.

# Obtaining Safety DB in BigQuery

I use the public database used by the [safety] package as a reference for which PyPI packages have known vulnerabilities.

Automation is provided to take care of making the current version of the [public Safety DB](https://github.com/pyupio/safety-db/tree/master/data) available as a BigQuery table. The source data is stored as a large JSON array, so needs a bit of processing before it can be loaded into BigQuery.

1. [etl/safety_db_to_jsonl.py](etl/safety_db_to_jsonl.py) downloads the July 1, 2022 update from GitHub and converts to a jsonlines format.
    - this script outputs to the `uncommitted` dir in the repo, which is `.gitignore`d. 
1. [etl/safety_jsonl_to_bq.py](etl/safety_jsonl_to_bq.py) loads the file produced by the previous script into a BigQuery table.
    - this script defaults to environment variables values matching those in your `.env` file. That seems like a sensible default but can be overridden with command line arguments.
