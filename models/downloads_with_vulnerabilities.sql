SELECT
    download.download_date,
    download.package,
    download.package_version,
    download.installer,
    download.download_count,
    vuln.cve,
    {{ target.schema }}.matches_multi_spec(vuln.specs, download.package_version) was_known_vulnerable_when_downloaded
FROM {{ ref('package_downloads_2024_01_30') }} download
    LEFT OUTER JOIN {{ ref('safety_vulnerabilities') }} vuln
        USING (package)