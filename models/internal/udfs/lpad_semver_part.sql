-- depends_on: {{ ref('internal') }}
{{ config(
    materialized='udf',
    parameter_list='part STRING',
    returns='STRING',
    description='Pads semver component to a fixed width lexically sortable value'
) }}

LPAD(part, 10, '0')
