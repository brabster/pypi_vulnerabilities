
WITH dated AS (
  SELECT
    package,
    DATE(commit_timestamp) commit_date,
    vulnerability.specs specs,
    vulnerability.cve cve,
    {{ ref('multi_spec_has_at_least_one_upper_bound') }}(vulnerability.specs) fix_was_available,
    ROW_NUMBER() OVER(PARTITION BY package, vulnerability.cve ORDER BY commit_timestamp) - 1 previous_commits
  FROM {{ source('safety_db', 'safety_db_history') }}
      CROSS JOIN UNNEST(vulnerabilities) vulnerability
)

SELECT
    *,
    COALESCE(
      LEAD(commit_date) OVER (
        PARTITION BY package, cve
        ORDER BY commit_date),
      DATE_ADD(commit_date, INTERVAL 1 MONTH)) until_date,
    previous_commits = 0 is_first_commit
FROM dated
