SELECT
    package,
    commit_date,
    vulnerability.specs specs,
    vulnerability.cve cve
FROM {{ source('safety_db', 'safety_db_2023_10_01') }}
    CROSS JOIN UNNEST(vulnerabilities) vulnerability