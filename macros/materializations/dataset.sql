{% materialization dataset, adapter='bigquery' %}
{%- set schema_name = this.schema if this.identifier == 'default' else this.schema ~ '_' ~ this.identifier -%}
{%- set schema_ref = adapter.quote(this.database ~ '.' ~ schema_name) -%}

{%- set description=config.get('description') -%}
{%- set location=config.get('location') -%}

{%- set dataset_exists_sql -%}
SELECT
  1
FROM
  `{{ this.database }}`.`region-{{ location }}`.INFORMATION_SCHEMA.SCHEMATA
WHERE schema_name = '{{ schema_name }}'
{%- endset -%}

{%- set dataset_exists = run_query(dataset_exists_sql) | length > 0 -%}
{%- set sql_op = 'ALTER SCHEMA' if dataset_exists else 'CREATE SCHEMA' -%}
{%- set options = 'SET OPTIONS' if dataset_exists else 'OPTIONS' -%}
{%- set location_option = '' if dataset_exists else "location='" ~ location ~ "'," -%}

{%- set update_sql -%}
{{ sql_op }} {{ schema_ref }}
{{ options }} (
    description='{{ description }}',
    {{ location_option }}
    labels=[('managed_by', 'dbt')]
) 
{%- endset -%}

{%- call statement('main') -%}
  {{ update_sql }}
{%- endcall %}

{%- set is_public = config.get('grant_public') -%}

{%- set grant_option = 'GRANT' if is_public else 'REVOKE' -%}
{%- set grant_to_from = 'TO' if is_public else 'FROM' -%}
{%- set grant_sql -%}
  {{ grant_option }} `roles/bigquery.dataViewer`
  ON SCHEMA {{ schema_ref }}
  {{ grant_to_from }} 'specialGroup:allUsers'
{%- endset -%}

{%- call statement('grant') -%}
  {{ grant_sql }}
{%- endcall %}

{{ return({'relations': []}) }}

{% endmaterialization %}