SELECT
    download_date,
    cve,
    SUM(download_count) downloads
FROM {{ ref('downloads_and_vulnerabilities') }}
WHERE was_known_vulnerable_when_downloaded
GROUP BY download_date, cve