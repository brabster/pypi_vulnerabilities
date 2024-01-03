WITH raw AS (
    SELECT
        was_vulnerable,
        download_sum,
        SUM(download_sum) OVER () total_downloads
    FROM {{ ref('download_vulnerability_cube') }}
    WHERE package_agg = 1 AND installer_agg = 1 AND was_vulnerable_agg = 0
)

SELECT
    download_sum downloads_with_known_vulnerabilities,
    total_downloads - download_sum downloads_without_known_vulnerabilities,
    SAFE_DIVIDE(download_sum, total_downloads) proportion_vulnerable_downloads
FROM raw

