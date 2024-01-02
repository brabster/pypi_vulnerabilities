SELECT
    DATE('2022-08-01') download_date,
    downloads.package,
    downloads.package_version,
    download_count,
    cve,
    installer,
    nvd_estimated_published_at,
    nvd_cvss_base_score,
    specs,
    {{ target.schema }}.matches_multi_spec(specs, package_version) was_known_vulnerable_when_downloaded
FROM {{ source('pypi', 'package_downloads_2022_08_01') }} downloads
    LEFT OUTER JOIN {{ ref('safety_vulnerabilities_with_meta') }} vulns
        ON downloads.package = vulns.package