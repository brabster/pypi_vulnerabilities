
{{ config(
    materialized='udf',
    parameter_list='prerelease STRING',
    returns='STRING',
    description='Extract prerelease prefix, if present. Example: "a" in "a1", "rc" in "rc3"'
) }}

COALESCE(REGEXP_EXTRACT(prerelease, r'^([^\d]+)'), '')
