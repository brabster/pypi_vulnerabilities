WITH examples AS (
    SELECT '3' clause, '3' expected,
    UNION ALL SELECT '2' clause, '2' expected
    UNION ALL SELECT '5.1' clause, '5.1' expected
    UNION ALL SELECT '5.1a0' clause, '5.10' expected
),

test AS (
    SELECT
        *,
        {{ target.schema }}.clean_semver(clause) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual != expected
