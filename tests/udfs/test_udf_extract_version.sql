WITH examples AS (
    SELECT '<3' clause, '3' expected,
    UNION ALL SELECT '<=3' clause, '3' expected
    UNION ALL SELECT '>=5.1' clause, '5.1' expected
    UNION ALL SELECT '>5.1' clause, '5.1' expected
    UNION ALL SELECT '>1.1.1' clause, '1.1.1' expected
),

test AS (
    SELECT
        *,
        {{ ref('extract_version')  }}(clause) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
