WITH raw AS (
    SELECT
        installer,
        was_vulnerable,
        download_sum,
        SUM(download_sum) OVER (PARTITION BY installer) total_installer_downloads
    FROM {{ ref('download_vulnerability_cube') }}
    WHERE package_agg = 1 AND installer_agg = 0 AND was_vulnerable_agg = 0
)

SELECT
    installer,
    download_sum downloads_with_known_vulnerabilities,
    total_installer_downloads - download_sum downloads_without_known_vulnerabilities,
    SAFE_DIVIDE(download_sum, total_installer_downloads) proportion_vulnerable_downloads
FROM raw
WHERE was_vulnerable