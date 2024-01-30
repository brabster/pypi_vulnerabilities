SELECT
    MAX(commit.timestamp) latest_commit_timestamp
FROM {{ source('safety_db', 'safety_db_history') }}