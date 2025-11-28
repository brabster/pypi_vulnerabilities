-- depends_on: {{ ref('file_downloads') }}
{{
    config(
        materialized='incremental',
        unique_key=['download_date', 'package', 'package_version', 'installer'],
        on_schema_change='fail',
        partition_by={
            'field': 'download_date',
            'data_type': 'date'
        },
        require_partition_filter = true,
        cluster_by=['package', 'package_version']
    )
}}


{% if is_incremental() %}
{% set latest_partition_date_sql %}
SELECT
  MAX(download_date)
FROM {{ this }}
WHERE download_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
{% endset %}

{% set latest_partition_date = dbt_utils.get_single_value(latest_partition_date_sql, '1970-01-01') %}

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

SELECT
    download_date1,
    package,
    package_version,
    installer,
    download_count
FROM `pypi-vulns.published_us_internal.daily_package_downloads`
{% endif %}