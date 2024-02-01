{{
    config(
        materialized='incremental',
        unique_key=['download_date', 'package', 'package_version', 'installer'],
        on_schema_change='fail'
    )
}}

SELECT
  download_date,
  package,
  package_version,
  installer,
  COUNT(1) AS download_count
FROM {{ ref('file_downloads') }}
WHERE download_date >= DATE('{{ env_var("DBT_PYPI_EARLIEST_DOWNLOAD_DATE") }}')

{% if is_incremental() %}
  AND download_date >= (SELECT MAX(download_date) FROM {{ this }})
{% endif %}

GROUP BY
  download_date,
  package,
  package_version,
  installer


