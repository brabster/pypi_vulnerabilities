SELECT
    1
FROM {{ ref('safety_vulnerabilities') }}
WHERE cve = 'CVE-2022-33124'
    AND package = 'aiohttp'
    AND NOT (
        commit_date = '2023-04-01'
        AND until_date = '2024-05-01' --CVE un-withdrawn by the looks of it, but test still checks there's a gap
    )
    AND commit_date < '2024-05-01' -- ignore subsequent changes
