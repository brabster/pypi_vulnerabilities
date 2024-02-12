-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='spec STRING, part_index INT64',
    returns='STRING',
    description='Extracts a semver part, defaulting to "0"'
) }}

COALESCE(SPLIT(spec, '.')[SAFE_OFFSET(part_index)], '0')
