WITH test AS (
    SELECT
        *,
        prerelease_suffix expected,
        {{ ref('extract_prerelease_suffix') }}(prerelease) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
