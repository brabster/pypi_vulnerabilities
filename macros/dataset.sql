{% macro dataset(description, labels, grant_public=False, sub_dataset_name=None, location=None) %}
{%- set location = location or var('location') -%}
{%- set description = description ~ '\n\nDocumentation at ' ~ var('docs_url') -%}
{%- set dataset_name = target.schema ~ '_' ~ sub_dataset_name if sub_dataset_name else target.schema -%}
{%- set dataset_ref = adapter.quote(target.database ~ '.' ~ dataset_name) -%}
{%- set all_labels = labels + [
  ('managed_by', 'dbt'),
  ('parent_schema', target.schema)
] -%}
{%- set is_public = grant_public | as_bool -%}

{%- set dataset_exists_sql -%}
SELECT
  1
FROM
  `{{ target.database }}`.`region-{{ location }}`.INFORMATION_SCHEMA.SCHEMATA
WHERE schema_name = '{{ dataset_name }}'
{%- endset -%}

{%- set dataset_exists = run_query(dataset_exists_sql) | length > 0 -%}
{%- set sql_op = 'ALTER SCHEMA' if dataset_exists else 'CREATE SCHEMA' -%}
{%- set options = 'SET OPTIONS' if dataset_exists else 'OPTIONS' -%}
{%- set location_option = '' if dataset_exists else "location='" ~ location ~ "'," -%}

{%- set update_sql -%}
{{ sql_op }} {{ dataset_ref }}
{{ options }} (
    description='''{{ description }}''',
    {{ location_option }}
    labels={{ all_labels }}
) 
{%- endset -%}

{%- do run_query(update_sql) -%}

{%- set grant_option = 'GRANT' if is_public else 'REVOKE' -%}
{%- set grant_to_from = 'TO' if is_public else 'FROM' -%}
{%- set grant_sql -%}
  {{ grant_option }} `roles/bigquery.dataViewer`
  ON SCHEMA {{ dataset_ref }}
  {{ grant_to_from }} 'specialGroup:allUsers'
{%- endset -%}

{%- do run_query(grant_sql) -%}

{% endmacro %}