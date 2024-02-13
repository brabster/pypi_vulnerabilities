
{{ config(
    materialized='udf',
    parameter_list='spec STRING',
    returns='STRING',
    description='Convert semver spec to a sortable string value. Supports up to 4 components, eg. 1.2.3.4'
) }}

{{ ref('semver_index_to_comparable') }}(spec, 0)
  || '.' || {{ ref('semver_index_to_comparable') }}(spec, 1)
  || '.' || {{ ref('semver_index_to_comparable') }}(spec, 2)
  || '.' || {{ ref('semver_index_to_comparable') }}(spec, 3)
