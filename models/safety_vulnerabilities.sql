SELECT
    package,
    commit_date,
    vulnerability.specs specs,
    vulnerability.cve cve
FROM {{ ref('safety_db_2023_10_01') }}
    CROSS JOIN UNNEST(vulnerabilities) vulnerability