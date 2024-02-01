SELECT
    *
FROM {{ ref('daily_package_downloads') }}
WHERE download_date = '2024-01-30'