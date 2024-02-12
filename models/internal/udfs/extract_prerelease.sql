-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='part STRING',
    returns='STRING',
    description='Extract a pre-release specification, if present. Example: "a0" in "0a0", "rc3" in "0-rc3". If no prerelease, "z" is used to sort behind any actual pre-release values'
) }}

COALESCE(
    REGEXP_EXTRACT(
        REPLACE(part, '-', ''), r'\d+([^\d].+)$'), 'z')
