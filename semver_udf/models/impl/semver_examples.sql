WITH examples AS (
    SELECT ['<4'] AS specs, ['1', '2', '3', '3.99', '3.99.99'] AS match, ['4', '4.0', '4.0.0'] AS do_not_match
    UNION ALL SELECT ['<=4'], ['1', '2', '3', '3.99', '3.99.99', '4', '4.0', '4.0.0'], ['4.1', '5', '4.0.1']
    UNION ALL SELECT ['>4'], ['4.1', '5', '5.0.1'], ['1', '2', '3', '3.99', '3.99.99', '4', '4.0', '4.0.0']
    UNION ALL SELECT ['>=4'], ['4.1', '5', '4.0.1'], ['1', '2', '3', '3.99', '3.99.99']
    UNION ALL SELECT ['>=5.1,<=5.1.2'], ['5.1', '5.1.1', '5.1.2'], ['1', '2', '3', '3.99', '3.99.99', '5.0', '5.0.1', '5.2', '5.1.3']
    UNION ALL SELECT ['<1.6a2'], ['1.5', '1.6a1'], ['1.6a2', '1.6']
    UNION ALL SELECT ['>=0,<1.2.21.7'], ['1', '1.2.21.6'], ['1.2.21.7']
    UNION ALL SELECT ['>=2.0.0a0,<2.0.2'], ['2.0.0a0', '2.0.0', '2.0.1'], ['2.0.2']
    UNION ALL SELECT ['<1.15.3', '>=2.0.0a0,<2.0.2'], ['1', '1.15.2', '2.0.0a0', '2.0.0', '2.0.1'], ['1.15.3', '2.0.2']
    UNION ALL SELECT ['>=2.0.0b0'], ['2.0.0b0', '2.0.0', '2.0.1a0'], ['2.0.0a0', '2.0.0a2']
    UNION ALL SELECT ['>=2.0.0a0,<2.0.0'], ['2.0.0a0', '2.0.0a2', '2.0.0b0'], ['2.0.0', '2.0.1a0']
    UNION ALL SELECT ['>=2.0.0-rc2,<2.0.0'], ['2.0.0-rc2', '2.0.0-rc3'], ['2.0.0a0', '2.0.0', '2.0.1a0']
)

SELECT
    specs,
    match package_version,
    TRUE should_match
FROM examples
    CROSS JOIN UNNEST(match) match
UNION ALL
SELECT
    specs,
    no_match package_version,
    FALSE should_match
FROM examples
    CROSS JOIN UNNEST(do_not_match) no_match
