WITH dated AS (
  SELECT
    package,
    DATE(commit_timestamp) commit_date,
    vulnerability.specs specs,
    vulnerability.cve cve
  FROM {{ source('safety_db', 'safety_db_history') }}
      CROSS JOIN UNNEST(vulnerabilities) vulnerability
)

SELECT
    *,
    COALESCE(
      LEAD(commit_date) OVER (
        PARTITION BY package, cve
        ORDER BY commit_date),
      CURRENT_DATE) until_date
FROM dated