-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='part STRING',
    returns='STRING',
    description='Extract semver string preceding pre-release specification, if present. Example: "0" in "0a0", "0" in "0-rc3"'
) }}

REGEXP_EXTRACT(part, r'^(\d+)')