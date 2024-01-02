{% macro ensure_udfs() %}
CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_op(spec STRING)
RETURNS STRING
OPTIONS (description='Extracts semver operator from specification string, eg. "<" in "<1.1.1"')
AS (
  REGEXP_EXTRACT(spec, r'^([<=>]+)')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_version(spec STRING)
RETURNS STRING
OPTIONS (description='Extracts semver version string from specification string, eg. "1.1.1" in "<1.1.1"')
AS (
  REGEXP_EXTRACT(spec, r'([^<=>]+)$')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.clean_semver(spec STRING)
RETURNS STRING
OPTIONS (description='Removes non-numeric and dot characters from semver string. Needs reviewing to handle alpha, beta, rc etc. versions')
AS (
  REGEXP_REPLACE(spec, r'[^0-9.]', '')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.pad_semver_part(spec STRING, part INT64)
RETURNS STRING
OPTIONS (description='Pads semver component to a fixed width lexically sortable value after removing non-numeric characters')
AS (
  LPAD(COALESCE(SPLIT({{ target.schema }}.clean_semver(spec), '.')[SAFE_OFFSET(part)], '0'), 10, '0')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.semver_to_comparable(spec STRING)
RETURNS STRING
OPTIONS (description='Convert semver spec to a sortable string value. Supports up to 4 components, eg. 1.2.3.4')
AS (
  {{ target.schema }}.pad_semver_part(spec, 0) || {{ target.schema }}.pad_semver_part(spec, 1) || {{ target.schema }}.pad_semver_part(spec, 2) || {{ target.schema }}.pad_semver_part(spec, 3)
);

CREATE OR REPLACE FUNCTION {{ target.schema }}. matches_spec(spec STRING, version STRING)
RETURNS BOOL
OPTIONS (description='True when the version string matches the spec. Example: 1.1.1 matches >1.1.0, does not match <1.1.1')
AS (
  CASE
    WHEN {{target.schema}}.extract_op(spec) = '<' THEN
      {{target.schema}}.semver_to_comparable(version) < {{target.schema}}.semver_to_comparable({{target.schema}}.extract_version(spec))
    WHEN {{target.schema}}.extract_op(spec) = '<=' THEN
      {{target.schema}}.semver_to_comparable(version) <= {{target.schema}}.semver_to_comparable({{target.schema}}.extract_version(spec))
    WHEN {{target.schema}}.extract_op(spec) = '>' THEN
      {{target.schema}}.semver_to_comparable(version) > {{target.schema}}.semver_to_comparable({{target.schema}}.extract_version(spec))
    WHEN {{target.schema}}.extract_op(spec) = '>=' THEN
      {{target.schema}}.semver_to_comparable(version) >= {{target.schema}}.semver_to_comparable({{target.schema}}.extract_version(spec))
    ELSE FALSE
  END
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.matches_maybe_compound_spec(spec STRING, version STRING)
RETURNS BOOL
OPTIONS (description='True when the version string matches the spec, where spec may have an upper and lower bound. Example: 1.1.1 matches >1.1.0,<1.1.2, does not match >1.1.0,<1.1.1')
AS (
  NOT EXISTS (SELECT 1 FROM UNNEST(SPLIT(spec, ',')) condition WHERE NOT {{ target.schema }}.matches_spec(condition, version))
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.matches_multi_spec(specs ARRAY<STRING>, version STRING)
RETURNS BOOL
OPTIONS (description='True when the version string matches any of an array of specs, where each spec may have an upper and lower bound. Example: 1.1.1 matches >1.1.0,<1.1.2, does not match >1.1.0,<1.1.1')
AS (
  EXISTS (SELECT 1 FROM UNNEST(specs) spec WHERE {{ target.schema }}.matches_maybe_compound_spec(spec, version))
);

{% endmacro %}