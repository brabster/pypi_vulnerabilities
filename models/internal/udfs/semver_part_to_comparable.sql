-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='part STRING',
    returns='STRING',
    description='Transforms a part of a semver string to a comparable representation'
) }}

  {{ ref('lpad_semver_part') }}({{ ref('extract_release') }}(part))
    || {{ ref('extract_prerelease_prefix') }}({{ ref('extract_prerelease') }}(part))
    || {{ ref('lpad_semver_part') }}({{ ref('extract_prerelease_suffix') }}({{ ref('extract_prerelease') }}(part)))
