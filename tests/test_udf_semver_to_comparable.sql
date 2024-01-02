WITH examples AS (
    SELECT '3' spec, '0000000003000000000000000000000000000000' expected
    UNION ALL SELECT '3.1.2273' spec, '0000000003000000000100000022730000000000' expected
    UNION ALL SELECT '3.1.2273a0' spec, '0000000003000000000100000227300000000000' expected
    UNION ALL SELECT '3.1.2273.4' spec, '0000000003000000000100000022730000000004' expected
),

test AS (
    SELECT
        *,
        {{ target.schema }}.semver_to_comparable(spec) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual != expected
