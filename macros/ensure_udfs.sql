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

CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_prerelease(part STRING)
RETURNS STRING
OPTIONS (description='Extract a pre-release specification, if present. Example: "a0" in "0a0", "rc3" in "0-rc3". If no prerelease, "z" is used to sort behind any actual pre-release values')
AS (
  COALESCE(REGEXP_EXTRACT(REPLACE(part, '-', ''), r'\d+([^\d].+)$'), 'z')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_release(part STRING)
RETURNS STRING
OPTIONS (description='Extract semver string preceding pre-release specification, if present. Example: "0" in "0a0", "0" in "0-rc3"')
AS (
  REGEXP_EXTRACT(part, r'^(\d+)')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_prerelease_suffix(prerelease STRING)
RETURNS STRING
OPTIONS (description='Extract prerelease suffix, if present. Example: "1" in "a1", "3" in "rc3"')
AS (
  COALESCE(REGEXP_EXTRACT(prerelease, r'.+?([\d]+)$'), '')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.extract_prerelease_prefix(prerelease STRING)
RETURNS STRING
OPTIONS (description='Extract prerelease prefix, if present. Example: "a" in "a1", "rc" in "rc3"')
AS (
  COALESCE(REGEXP_EXTRACT(prerelease, r'^([^\d]+)'), '')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.safe_extract_semver_part(spec STRING, part_index INT64)
RETURNS STRING
OPTIONS (description='Extracts a semver part, defaulting to "0"')
AS (
  COALESCE(SPLIT(spec, '.')[SAFE_OFFSET(part_index)], '0')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.lpad_semver_part(part STRING)
RETURNS STRING
OPTIONS (description='Pads semver component to a fixed width lexically sortable value')
AS (
  LPAD(part, 10, '0')
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.semver_part_to_comparable(part STRING)
RETURNS STRING
OPTIONS (description='Transforms a part of a semver string to a comparable representation')
AS (
  {{ target.schema }}.lpad_semver_part({{ target.schema }}.extract_release(part))
    || {{ target.schema }}.extract_prerelease_prefix({{ target.schema }}.extract_prerelease(part))
    || {{ target.schema }}.lpad_semver_part({{ target.schema }}.extract_prerelease_suffix({{ target.schema }}.extract_prerelease(part)))
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.semver_index_to_comparable(spec STRING, part_index INT64)
RETURNS STRING
OPTIONS (description='Convert indexed part of a full semver string to comparable')
AS (
  {{ target.schema }}.semver_part_to_comparable({{ target.schema }}.safe_extract_semver_part(spec, part_index))
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.semver_to_comparable(spec STRING)
RETURNS STRING
OPTIONS (description='Convert semver spec to a sortable string value. Supports up to 4 components, eg. 1.2.3.4')
AS (
  {{ target.schema }}.semver_index_to_comparable(spec, 0)
  || '.' || {{ target.schema }}.semver_index_to_comparable(spec, 1)
  || '.' || {{ target.schema }}.semver_index_to_comparable(spec, 2)
  || '.' || {{ target.schema }}.semver_index_to_comparable(spec, 3)
);

CREATE OR REPLACE FUNCTION {{ target.schema }}.matches_spec(spec STRING, version STRING)
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