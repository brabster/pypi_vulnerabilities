{% macro ensure_dataset(region='US', is_public=False) -%}
{% if execute %}
    {% set dataset_ref = '`' ~ target.database ~ '.' ~ target.schema ~ '`' %}
    
    {% set query %}
        {% do log('Ensuring dataset ' ~ dataset_ref ~ ' exists') %}
        CREATE SCHEMA IF NOT EXISTS {{ dataset_ref }}
        OPTIONS(
            location = '{{ region }}',
            description = '',
            labels = [('dbt-provisioned', 'true')]
        )
    {% endset %}
    {% do run_query(query) %}

    {%- set grant_option = 'GRANT' if is_public else 'REVOKE' -%}
    {%- set grant_to_from = 'TO' if is_public else 'FROM' -%}
    {%- set grant_sql -%}
    {{ grant_option }} `roles/bigquery.dataViewer`
    ON SCHEMA {{ dataset_ref }}
    {{ grant_to_from }} 'specialGroup:allUsers'
    {%- endset -%}

    {%- do run_query(grant_sql) -%}

{% endif %}
{%- endmacro %}