SELECT
    '1.' || semver spec,
    '0000000001z0000000000.' || comparable || '.0000000000z0000000000.0000000000z0000000000' comparable
FROM {{ ref('semver_prerelease_examples') }}
UNION ALL
SELECT
    '0.' || semver spec,
    '0000000000z0000000000.' || comparable || '.0000000000z0000000000.0000000000z0000000000' comparable
FROM {{ ref('semver_prerelease_examples') }}
