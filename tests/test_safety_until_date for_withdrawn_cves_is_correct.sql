SELECT
    1
FROM {{ ref('safety_vulnerabilities') }}
WHERE cve = 'CVE-2022-33124'
    AND package = 'aiohttp'
    AND NOT (
        commit_date = '2023-04-01'
        AND until_date = '2023-05-01'
    )