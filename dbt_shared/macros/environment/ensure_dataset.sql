{% macro ensure_dataset(region='US') -%}
{% if execute %}
    {% set query %}
        {% set dataset_ref = '`' ~ target.database ~ '.' ~ target.schema ~ '`' %}
        {% do log('Ensuring dataset ' ~ dataset_ref ~ ' exists') %}
        CREATE SCHEMA IF NOT EXISTS {{ dataset_ref }}
        OPTIONS(
            location = '{{ region }}',
            description = '',
            labels = [('dbt-provisioned', 'true')]
        )
    {% endset %}
    {% do run_query(query) %}
{% endif %}
{%- endmacro %}