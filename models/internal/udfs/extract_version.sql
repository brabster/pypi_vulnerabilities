-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='spec STRING',
    returns='STRING',
    description='Extracts semver version string from specification string, eg. "1.1.1" in "<1.1.1"'
) }}

REGEXP_EXTRACT(spec, r'([^<=>]+)$')
