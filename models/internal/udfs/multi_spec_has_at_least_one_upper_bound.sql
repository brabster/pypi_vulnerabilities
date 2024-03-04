
{{ config(
    materialized='udf',
    parameter_list='specs ARRAY<STRING>',
    returns='BOOL',
    description='True if at least one version specification in the set includes an upper bound. See test for examples.'
) }}

TRUE IN (SELECT {{ ref('spec_has_upper_bound') }}(spec) FROM UNNEST(specs) spec)

