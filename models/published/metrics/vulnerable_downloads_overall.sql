WITH raw AS (
    SELECT
        download_date,
        was_vulnerable,
        download_sum,
        SUM(download_sum) OVER (PARTITION BY download_date) total_downloads
    FROM {{ ref('download_vulnerability_cube') }}
    WHERE download_date_agg = 0
        AND package_agg = 1
        AND installer_agg = 1
        AND was_vulnerable_agg = 0
)

SELECT
    download_date,
    was_vulnerable,
    download_sum downloads,
    SAFE_DIVIDE(download_sum, total_downloads) proportion_vulnerable_downloads
FROM raw

