{% macro ensure_single_day_downloads_materialized() %}
CREATE TABLE IF NOT EXISTS {{ target.schema }}.package_downloads_2023_11_05 AS
SELECT
    download_date,
    package,
    package_version,
    installer,
    download_count
FROM {{ target.schema }}.daily_package_downloads
WHERE download_date = '2023-11-05'
{% endmacro %}