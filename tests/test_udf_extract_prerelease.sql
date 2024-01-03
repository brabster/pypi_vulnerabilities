WITH test AS (
    SELECT
        *,
        prerelease expected,
        {{ target.schema }}.extract_prerelease(semver) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
