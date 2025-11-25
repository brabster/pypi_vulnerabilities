-- source: https://revoltbi.medium.com/automatically-identify-delete-orphaned-tables-and-schemas-dbt-macro-ea1ec642cd71

-- MACRO DESCRIPTION
-- This macro is designed to clean up orphaned tables and schemas from your database that are no longer managed by dbt.
-- It offers flexibility to either log the drop commands for review or execute them directly.

{%- macro drop_redundant_models(objects_type=['VIEW', 'BASE_TABLE'], dry_run=true, tables_to_exclude=[''], delete_custom_schemas=false, schemas_to_exclude=['']) -%}

-- PARAMETERS:
-- dry_run (default: 'true'): If set to 'true', gitthe macro logs the drop commands without executing them. If set to 'false', the macro executes the drop commands.
-- tables_to_exclude: A list of table names to exclude from being dropped.
-- delete_custom_schemas (default: 'false'): If set to 'true', the macro will drop schemas that are not managed by dbt. If set to 'false', it will only drop orphaned tables.
-- schemas_to_exclude: A list of schema names to exclude from being dropped.
-- objects_type: Mandatory parameter, A list of object type to be dropped, available objects types are VIEW, BASE TABLE, MANAGED 

-- TODO: objects_type  if not defined DROP ALL object types

    {% if not objects_type %}
        {% do exceptions.raise_compiler_error('objects_type not provided') %}
    {% endif %}

    {%- set schemas_to_exclude = schemas_to_exclude + ['monitoring', 'information_schema'] -%}
    {%- set tables_to_exclude = tables_to_exclude + ['config_table','mapping_table'] -%}
    {%- if execute -%}

        -- Create empty dictionary that will contain the hierarchy of the models in dbt
        {%- set current_model_locations = {} -%}

        -- Insert the hierarchy database.schema.table in the dictionary above
        {%- for node in graph.nodes.values() | selectattr("resource_type", "in", ["model", "seed", "snapshot"]) -%}

            {% if target.type == 'bigquery' %}
              {%- set database_name = node.database -%}
            {%- else -%}
              {%- set database_name = node.database.upper() -%}
            {% endif %}
            {%- set schema_name = node.schema.upper() -%}
            {%- set table_name = node.alias if node.alias else node.name -%}

            -- Add db name if it does not exist in the dict
            {%- if not database_name in current_model_locations -%}
                {% do current_model_locations.update({database_name: {}}) -%}
            {%- endif -%}

            -- Add schema name if it does not exist in the dict
            {%- if not schema_name in current_model_locations[database_name] -%}
                {% do current_model_locations[database_name].update({schema_name: []}) -%}
            {%- endif -%}

            -- Add the tables for the db and schema selected
            {%- do current_model_locations[database_name][schema_name].append(table_name.upper()) -%}

        {%- endfor -%}

        {% set target_table %}
        {% if target.type == 'bigquery' %}
            {{ target.project }}.{{ target.dataset }}.INFORMATION_SCHEMA.TABLES
        {%- else -%}
            {{ target.database }}.INFORMATION_SCHEMA.TABLES
        {% endif %}
        {% endset %}

        -- Query to retrieve the models to drop
        {%- set cleanup_query -%}

            WITH models_to_drop AS (
                {%- for database in current_model_locations.keys() -%}

                    SELECT
                        CASE
                            WHEN table_type not in (
                                {%- for object_type in objects_type -%}
                                '{{ object_type|upper }}'
                                {%- if not loop.last %} , {%- endif %}
                                {%- endfor %} ) THEN NULL
                            WHEN table_type in ('BASE TABLE', 'MANAGED') THEN 'TABLE'
                            WHEN table_type = 'VIEW' THEN 'VIEW'
                            ELSE NULL
                        END AS relation_type,
                        table_catalog,
                        table_schema,
                        table_name,
                        table_catalog || '.' || table_schema || '.' || table_name as relation_name
                    FROM {{ target_table }}
                    WHERE 1=1

                        AND LOWER(table_schema) IN ('{{ "', '".join(current_model_locations[database].keys())|lower }}')
                        AND NOT (
                            {%- for schema in current_model_locations[database].keys() -%}
                                LOWER(table_schema) = LOWER('{{ schema }}') AND LOWER(table_name) IN ('{{ "', '".join(current_model_locations[database][schema])|lower }}')
                                {% if not loop.last %} OR {% endif %}
                            {%- endfor %}
                        )


    -- Exclude tables containing any of the keywords
                        AND NOT (
                            {%- for keyword in tables_to_exclude -%}
                                LOWER(table_name) IN ('{{ keyword|lower }}')
                                {% if not loop.last %} OR {% endif %}
                            {%- endfor %}
                        )


                    {% if not loop.last -%} UNION ALL {%- endif %}

            ),

            drop_schemas AS (
                SELECT DISTINCT table_catalog, table_schema
                FROM {{ target_table }}
                WHERE 1=1
                AND LOWER(table_schema) NOT IN ('{{ current_model_locations[database].keys() | join("', '") | lower }}')
                AND LOWER(table_schema) NOT IN ('{{ schemas_to_exclude | join("', '") | lower }}')
    -- Exclude schemas from macro settings
                    AND NOT (
                        {%- for schema in schemas_to_exclude -%}
                            LOWER(table_schema) IN ('{{ schema|lower }}')
                            {% if not loop.last %} OR {% endif %}
                        {%- endfor %}
                    )
                {%- endfor -%}
            )

            -- Create the DROP statments to be executed in the database
                    SELECT 'DROP ' || relation_type || ' IF EXISTS `' || table_catalog || '.' || table_schema || '.' || table_name || '`;' AS drop_commands
                    FROM models_to_drop
                    WHERE relation_type IS NOT NULL

                    {% if delete_custom_schemas == true %}
                    UNION ALL

                    SELECT 'DROP SCHEMA IF EXISTS `' || table_catalog || '.' || table_schema || '` CASCADE;' AS drop_commands
                    FROM drop_schemas
                    {% endif %}

        {%- endset -%}


        {{ log('Generating cleanup queries...', info=True) }}

        -- Execute the DROP statments above
        {%- if dry_run == false -%}
            {%- set drop_commands = run_query(cleanup_query).columns[0].values() -%}
            {%- for drop_command in drop_commands -%}
                {%- do log(drop_command, True) -%}
                {%- do run_query(drop_command) -%}
            {%- endfor -%}
        {%- else -%}
            -- Log the drop commands in dry run mode
            {%- set drop_commands = run_query(cleanup_query).columns[0].values() -%}
            {%- for drop_command in drop_commands -%}
                {%- do log(drop_command, True) -%}
            {%- endfor -%}
        {%- endif -%}

    {%- endif %}

    SELECT 1

{% endmacro -%}