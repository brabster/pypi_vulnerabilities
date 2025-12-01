
{{ config(
    materialized='udf',
    parameter_list='spec STRING, part_index INT64',
    returns='STRING',
    description='Convert indexed part of a full semver string to comparable'
) }}

{{ ref('semver_part_to_comparable') }}({{ ref('safe_extract_semver_part') }}(spec, part_index))
