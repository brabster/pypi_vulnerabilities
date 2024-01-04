WITH raw AS (
    SELECT
        package,
        was_vulnerable,
        download_sum,
        SUM(download_sum) OVER (PARTITION BY package) total_package_downloads
    FROM {{ ref('download_vulnerability_cube') }}
    WHERE package_agg = 0 AND installer_agg = 1 AND was_vulnerable_agg = 0
)

SELECT
    package,
    download_sum downloads_with_known_vulnerabilities,
    total_package_downloads - download_sum downloads_without_known_vulnerabilities,
    SAFE_DIVIDE(download_sum, total_package_downloads) proportion_vulnerable_downloads
FROM raw
WHERE was_vulnerable