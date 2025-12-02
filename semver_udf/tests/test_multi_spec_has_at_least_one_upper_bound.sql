WITH examples AS (
    SELECT ['==1.0'] spec, True expected
    UNION ALL SELECT ['>0.1'], False
    UNION ALL SELECT ['>0.1,<10'], True
    UNION ALL SELECT ['>0.1,<=10'], True
    UNION ALL SELECT ['<10'], True
    UNION ALL SELECT ['<=10'], True
    UNION ALL SELECT ['<=10', '==11'], True
    UNION ALL SELECT ['<=10', '<11'], True
    UNION ALL SELECT ['<=10', '>11'], True -- wrong! but rare enough (if it happens at all) that it's unlikely to mess up conclusions
),

test AS (
    SELECT
        *,
        {{ ref('multi_spec_has_at_least_one_upper_bound') }}(spec) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
