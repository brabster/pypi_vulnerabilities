{% macro grant_schemas(schemas, grant_view_to=[], revoke_view_from=[]) -%}
{% if execute %}
{% for schema in schemas %}
    {% if grant_view_to|length > 0 and not schema.endswith('_impl') %}

        {%- set grant_sql -%}
        GRANT `roles/bigquery.dataViewer`
        ON SCHEMA {{ schema }}
        TO
            {% for principal in grant_view_to %}
            '{{ principal }}'{{ ", " if not loop.last else "" }}
            {% endfor %}
        {%- endset -%}

        {%- do run_query(grant_sql) -%}
    {% endif %}

    {% if revoke_view_from|length > 0 %}
    {%- set revoke_sql -%}
    REVOKE `roles/bigquery.dataViewer`
    ON SCHEMA {{ schema }}
    FROM
        {% for principal in revoke_view_from %}
        '{{ principal }}'{{ ", " if not loop.last else "" }}
        {% endfor %}
    {%- endset -%}

    {%- do run_query(revoke_sql) -%}
    {% endif %}

{% endfor %}
{% endif %}

{%- endmacro %}