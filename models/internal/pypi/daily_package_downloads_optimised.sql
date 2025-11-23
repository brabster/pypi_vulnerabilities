{{
    config(
        materialized='incremental',
        unique_key=['download_date', 'package', 'package_version', 'installer'],
        on_schema_change='fail',
        partition_by={
            'field': 'download_date',
            'data_type': 'date'
        },
        cluster_by=['package', 'package_version']
    )
}}

{% set latest_partition_date_sql %}
  SELECT MAX(download_date) FROM {{ this }}
{% endset %}

{% set latest_partition_date = dbt_utils.get_single_value(latest_partition_date_sql, '1970-01-01') %}

{% if is_incremental() %}
  {# Incremental run: process only new data from source #}
  SELECT
    download_date,
    package,
    package_version,
    installer,
    COUNT(1) AS download_count
  FROM {{ ref('file_downloads') }}
  WHERE download_date >= DATE('{{ env_var("DBT_PYPI_EARLIEST_DOWNLOAD_DATE") }}')
    AND download_date >= '{{ latest_partition_date }}'
  GROUP BY
    download_date,
    package,
    package_version,
    installer

{% else %}
  {# Initial run: bootstrap from existing daily_package_downloads table #}
  
  {% set old_table_latest_date_sql %}
    SELECT COALESCE(MAX(download_date), DATE('1970-01-01')) FROM {{ ref('daily_package_downloads') }}
  {% endset %}
  
  {% set old_table_latest_date = dbt_utils.get_single_value(old_table_latest_date_sql, '1970-01-01') %}
  
  SELECT
    download_date,
    package,
    package_version,
    installer,
    download_count
  FROM {{ ref('daily_package_downloads') }}

  UNION ALL

  {# Then add any new data that appeared in source since the old table was last updated #}
  SELECT
    download_date,
    package,
    package_version,
    installer,
    COUNT(1) AS download_count
  FROM {{ ref('file_downloads') }}
  WHERE download_date >= DATE('{{ env_var("DBT_PYPI_EARLIEST_DOWNLOAD_DATE") }}')
    AND download_date > '{{ old_table_latest_date }}'
  GROUP BY
    download_date,
    package,
    package_version,
    installer

{% endif %}
