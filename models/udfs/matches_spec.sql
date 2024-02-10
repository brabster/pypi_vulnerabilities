{{ config(
    materialized='udf',
    parameter_list='spec STRING, version STRING',
    returns='BOOL',
    description='True when the version string matches the spec. Example: 1.1.1 matches >1.1.0, does not match <1.1.1'
) }}

CASE
    WHEN {{ ref('extract_op') }}(spec) = '<' THEN
        {{ ref('semver_to_comparable') }}(version) < {{ ref('semver_to_comparable') }}({{ ref('extract_version') }}(spec))
    WHEN {{ ref('extract_op') }}(spec) = '<=' THEN
        {{ ref('semver_to_comparable') }}(version) <= {{ ref('semver_to_comparable') }}({{ ref('extract_version') }}(spec))
    WHEN {{ ref('extract_op') }}(spec) = '>' THEN
        {{ ref('semver_to_comparable') }}(version) > {{ ref('semver_to_comparable') }}({{ ref('extract_version') }}(spec))
    WHEN {{ ref('extract_op') }}(spec) = '>=' THEN
        {{ ref('semver_to_comparable') }}(version) >= {{ ref('semver_to_comparable') }}({{ ref('extract_version') }}(spec))
    ELSE FALSE
END
