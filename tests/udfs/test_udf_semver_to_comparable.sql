WITH test AS (
    SELECT
        *,
        comparable expected,
        {{ ref('semver_to_comparable') }}(spec) actual
    FROM {{ ref('semver_prerelease_full_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
