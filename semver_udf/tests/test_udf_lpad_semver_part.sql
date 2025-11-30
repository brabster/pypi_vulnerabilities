WITH examples AS (
    SELECT '3' clause, '0000000003' expected
    UNION ALL SELECT '1' clause, '0000000001' expected
    UNION ALL SELECT '2273' clause, '0000002273' expected
    UNION ALL SELECT '2273a0' clause, '00002273a0' expected
),

test AS (
    SELECT
        *,
        {{ ref('lpad_semver_part') }}(clause) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
