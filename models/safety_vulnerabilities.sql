SELECT
    package,
    DATE(commit_timestamp) commit_date,
    vulnerability.specs specs,
    vulnerability.cve cve
FROM {{ ref('safety_db_2024_01_01') }}
    CROSS JOIN UNNEST(vulnerabilities) vulnerability