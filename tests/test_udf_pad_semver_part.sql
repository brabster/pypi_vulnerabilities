WITH examples AS (
    SELECT '3' clause, 0 part, '0000000003' expected
    UNION ALL SELECT '3' clause, 1 part, '0000000000' expected
    UNION ALL SELECT '3.1.2273' clause, 0 part, '0000000003' expected
    UNION ALL SELECT '3.1.2273' clause, 1 part, '0000000001' expected
    UNION ALL SELECT '3.1.2273' clause, 2 part, '0000002273' expected
    UNION ALL SELECT '3.1.2273a0' clause, 2 part, '0000022730' expected
    UNION ALL SELECT '3.1.2273.4' clause, 3 part, '0000000004' expected
),

test AS (
    SELECT
        *,
        {{ target.schema }}.pad_semver_part(clause, part) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual != expected
