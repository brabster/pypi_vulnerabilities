{{ config(
    materialized='udf',
    parameter_list='specs ARRAY<STRING>, version STRING',
    returns='BOOL',
    description='True when the version string matches any of an array of specs, where each spec may have an upper and lower bound. Example: 1.1.1 matches >1.1.0,<1.1.2, does not match >1.1.0,<1.1.1"'
) }}

EXISTS (SELECT 1 FROM UNNEST(specs) spec WHERE {{ ref('matches_maybe_compound_spec') }}(spec, version))
