WITH test AS (
    SELECT
        *,
        release expected,
        {{ target.schema }}.extract_release(semver) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
