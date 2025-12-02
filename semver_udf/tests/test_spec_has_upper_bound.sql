WITH examples AS (
    SELECT '==1.0' spec, True expected
    UNION ALL SELECT '>0.1', False
    UNION ALL SELECT '>0.1,<10', True
    UNION ALL SELECT '>0.1,<=10', True
    UNION ALL SELECT '<10', True
    UNION ALL SELECT '<=10', True
),

test AS (
    SELECT
        *,
        {{ ref('spec_has_upper_bound') }}(spec) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
