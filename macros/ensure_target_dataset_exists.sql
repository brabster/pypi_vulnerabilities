{% macro ensure_target_dataset_exists() %}

    {% set project_id = target.project %}
    {% set dataset_name = target.schema %}
    {% set dataset_location = target.location %}

    {{ print("Ensuring dataset " ~ project_id ~ "." ~ dataset_name ~ " exists in location " ~ dataset_location ) }}

    {% set create_dataset_query %}
    CREATE SCHEMA IF NOT EXISTS `{{ project_id }}`.`{{ dataset_name }}`
    OPTIONS (
        description = 'Exploring vulnerable PyPI downloads. Managed by https://github.com/brabster/pypi_vulnerabilities',
        location = '{{ dataset_location }}',
        labels = [('data_classification', 'public')]
    )
    {% endset %}

    {% if execute %}
        {% set results = run_query(create_dataset_query) %}
    {% endif %}

{% endmacro %}