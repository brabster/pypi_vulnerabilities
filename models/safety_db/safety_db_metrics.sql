SELECT
    commit_timestamp,
    TO_JSON_STRING(commit) commit_details,
    COUNT(1) package_count
FROM {{ source('safety_db', 'safety_db_history') }}
GROUP BY commit_timestamp, commit_details