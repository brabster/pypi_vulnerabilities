{{ config(
    materialized='udf',
    parameter_list='spec STRING',
    returns='STRING',
    description='Extracts semver operator from specification string, eg. "<" in "<1.1.1"'
) }}

REGEXP_EXTRACT(spec, r'^([<=>]+)')
