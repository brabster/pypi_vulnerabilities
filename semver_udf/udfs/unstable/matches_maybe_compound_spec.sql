
{{ config(
    materialized='udf',
    parameter_list='spec STRING, version STRING',
    returns='BOOL',
    description='True when the version string matches the spec, where spec may have an upper and lower bound. Example: 1.1.1 matches >1.1.0,<1.1.2, does not match >1.1.0,<1.1.1'
) }}

NOT EXISTS (SELECT 1 FROM UNNEST(SPLIT(spec, ',')) condition WHERE NOT {{ ref('matches_spec') }}(condition, version))
