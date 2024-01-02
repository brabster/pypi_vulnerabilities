SELECT
    DATE('2022-08-01') download_date,
    package,
    package_version,
    installer,
    was_known_vulnerable_when_downloaded,
    download_count,
    ARRAY_AGG(STRUCT(cve, nvd_cvss_base_score)) cves
FROM {{ ref('downloads_with_vulnerabilities') }}
GROUP BY
    download_date,
    package,
    package_version,
    installer,
    was_known_vulnerable_when_downloaded,
    download_count
