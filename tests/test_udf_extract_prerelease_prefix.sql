WITH test AS (
    SELECT
        *,
        prerelease_prefix expected,
        {{ target.schema }}.extract_prerelease_prefix(prerelease) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
