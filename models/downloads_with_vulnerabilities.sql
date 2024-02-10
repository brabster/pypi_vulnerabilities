SELECT
    download.download_date,
    download.package,
    download.package_version,
    download.installer,
    download.download_count,
    vuln.cve,
    vuln.commit_date,
    {{ ref('matches_multi_spec') }}(vuln.specs, download.package_version) was_known_vulnerable_when_downloaded
FROM {{ ref('daily_package_downloads') }} download
    LEFT OUTER JOIN {{ ref('safety_vulnerabilities') }} vuln
        ON download.package = vuln.package
            AND download.download_date >= vuln.commit_date
            AND download.download_date < vuln.until_date