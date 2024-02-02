WITH raw AS (
    SELECT
        download_date,
        package,
        was_vulnerable,
        download_sum,
        SUM(download_sum) OVER (PARTITION BY package) total_package_downloads
    FROM {{ ref('download_vulnerability_cube') }}
    WHERE download_date_agg = 1
        AND package_agg = 0
        AND installer_agg = 1
        AND was_vulnerable_agg = 0
)

SELECT
    download_date,
    package,
    was_vulnerable,
    download_sum downloads,
    SAFE_DIVIDE(download_sum, total_package_downloads) proportion_vulnerable_downloads
FROM raw
WHERE was_vulnerable
