WITH test AS (
    SELECT
        *,
        comparable expected,
        {{ ref('semver_part_to_comparable') }}(semver) actual
    FROM {{ ref('semver_prerelease_examples') }}
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
