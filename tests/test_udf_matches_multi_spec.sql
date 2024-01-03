WITH examples AS (
    SELECT
        specs,
        package_version,
        should_match expected
    FROM {{ ref('semver_examples') }}
),

test AS (
    SELECT
        *,
        {{ target.schema }}.matches_multi_spec(specs, package_version) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
