WITH examples AS (
    SELECT
        specs[SAFE_OFFSET(0)] spec,
        package_version,
        should_match expected
    FROM {{ ref('semver_examples') }}
    WHERE ARRAY_LENGTH(specs) = 1
        AND specs[SAFE_OFFSET(0)] NOT LIKE '%,%'
),

test AS (
    SELECT
        *,
        {{ target.schema }}.matches_spec(spec, package_version) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
