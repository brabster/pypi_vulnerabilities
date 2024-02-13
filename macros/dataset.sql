{% macro dataset(location, description, labels, grant_public=False, sub_dataset_name=None) %}
{%- set dataset_name = target.schema ~ '_' ~ sub_dataset_name if sub_dataset_name else target.schema -%}
{%- set dataset_ref = adapter.quote(target.database ~ '.' ~ dataset_name) -%}
{%- set all_labels = labels + [('managed_by', 'dbt'), ('parent_schema', target.schema)] -%}

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
    description='{{ description }}',
    {{ location_option }}
    labels={{ all_labels }}
) 
{%- endset -%}

{%- call statement('main') -%}
  {{ update_sql }}
{%- endcall %}

{%- set grant_option = 'GRANT' if is_public else 'REVOKE' -%}
{%- set grant_to_from = 'TO' if is_public else 'FROM' -%}
{%- set grant_sql -%}
  {{ grant_option }} `roles/bigquery.dataViewer`
  ON SCHEMA {{ dataset_ref }}
  {{ grant_to_from }} 'specialGroup:allUsers'
{%- endset -%}

{%- call statement('grant') -%}
  {{ grant_sql }}
{%- endcall %}

{% endmacro %}