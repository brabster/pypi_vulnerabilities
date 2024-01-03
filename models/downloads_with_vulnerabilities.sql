SELECT
    download.download_date,
    download.package,
    download.package_version,
    download.installer,
    download.download_count,
    vuln.cve,
    {{ target.schema }}.matches_multi_spec(vuln.specs, download.package_version) was_known_vulnerable_when_downloaded
FROM {{ source('pypi-vulnerabilities', 'package_downloads_2023_11_05') }} download
    LEFT OUTER JOIN {{ ref('safety_vulnerabilities') }} vuln
        USING (package)