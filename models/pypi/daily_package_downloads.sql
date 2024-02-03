{{
    config(
        materialized='incremental',
        unique_key=['download_date', 'package', 'package_version', 'installer'],
        on_schema_change='fail'
    )
}}

{% set latest_partition_date_sql %}
  SELECT MAX(download_date) FROM {{ this }}
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

{% if is_incremental() %}
  AND download_date >= '{{ latest_partition_date }}'
{% endif %}

GROUP BY
  download_date,
  package,
  package_version,
  installer


