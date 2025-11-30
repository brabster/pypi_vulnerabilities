
{{ config(
    materialized='udf',
    parameter_list='prerelease STRING',
    returns='STRING',
    description='Extract prerelease suffix, if present. Example: "1" in "a1", "3" in "rc3"'
) }}

COALESCE(REGEXP_EXTRACT(prerelease, r'.+?([\d]+)$'), '')
