{{ config(materialized='table') }}
WITH grouped_vulnerabilities AS (
    SELECT
        download_date,
        package,
        package_version,
        installer,
        download_count,
        ARRAY_AGG(STRUCT(cve, commit_date, was_known_vulnerable_when_downloaded)) maybe_cves
    FROM {{ ref('downloads_with_vulnerabilities') }}
    WHERE cve IS NOT NULL
    GROUP BY
        download_date,
        package,
        package_version,
        installer,
        download_count
),

filtered_by_vulnerable AS (
    SELECT
        *,
        ARRAY(SELECT STRUCT(cve.cve, cve.commit_date) FROM UNNEST(maybe_cves) cve WHERE cve.was_known_vulnerable_when_downloaded) vulnerabilities
    FROM grouped_vulnerabilities
)

SELECT
    * EXCEPT (maybe_cves),
    ARRAY_LENGTH(vulnerabilities) cve_count,
    ARRAY_LENGTH(vulnerabilities) > 0 was_vulnerable
FROM filtered_by_vulnerable
