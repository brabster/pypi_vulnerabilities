{{ config(warn_if = '<2', error_if = '<2') }}

WITH examples AS (
    SELECT DATE('2023-08-01') commit_date, 0 previous_commits
    UNION ALL SELECT '2023-09-01', 1
)

SELECT
    1
FROM {{ ref('safety_vulnerabilities') }}
    INNER JOIN examples
        USING (commit_date, previous_commits)
WHERE package = 'apimatic-core'
    AND cve = 'CVE-2023-32681'
