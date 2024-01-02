WITH examples AS (
    SELECT '<3' clause, '<' expected,
    UNION ALL SELECT '<=2' clause, '<=' expected
    UNION ALL SELECT '>=5.1' clause, '>=' expected
    UNION ALL SELECT '>5.1' clause, '>' expected
),

test AS (
    SELECT
        *,
        {{ target.schema }}.extract_op(clause) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual != expected
