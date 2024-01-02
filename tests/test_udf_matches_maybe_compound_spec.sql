WITH examples AS (
    SELECT
        specs[SAFE_OFFSET(0)] spec,
        package_version,
        should_match expected
    FROM {{ ref('semver_examples') }}
    WHERE ARRAY_LENGTH(specs) = 1
),

test AS (
    SELECT
        *,
        {{ target.schema }}.matches_maybe_compound_spec(spec, package_version) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual != expected
