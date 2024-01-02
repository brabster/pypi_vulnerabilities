{% macro ensure_target_dataset_exists() %}

    {% set project_id = target.project %}
    {% set dataset_name = target.schema %}
    {% set dataset_location = target.location %}

    {% do log("Ensuring dataset " ~ project_id ~ "." ~ dataset_name ~ " exists in location " ~ dataset_location ) %}

    CREATE SCHEMA IF NOT EXISTS `{{ project_id }}`.`{{ dataset_name }}`
    OPTIONS (
        location = '{{ dataset_location }}'
    )

{% endmacro %}