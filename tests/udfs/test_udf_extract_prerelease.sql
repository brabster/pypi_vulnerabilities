WITH test AS (
    SELECT
        *,
        prerelease expected,
        {{ ref('extract_prerelease') }}(semver) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
