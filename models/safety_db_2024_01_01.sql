SELECT
    *
FROM {{ source('safety_db', 'safety_db_history') }}
WHERE DATE(commit_timestamp) = '2024-01-01'