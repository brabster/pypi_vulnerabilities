{%- macro nodes_to_bq_refs(nodes) -%}
    {%- set node_refs = [] -%}
    {%- for node in nodes | list -%}
        {%- do node_refs.append(node.database ~ '.' ~ node.schema ~ '.' ~ node.name) -%}
    {%- endfor -%}
    {{ return(node_refs) }}
{%- endmacro -%}

{%- macro drop_orphaned_udfs() -%}
    {%- set active_udfs = graph.nodes.values()
        | selectattr('resource_type', 'in', ['model', 'seed'])
        | selectattr('config.materialized', 'in', ['udf']) -%}

    {%- set active_udf_refs = nodes_to_bq_refs(active_udfs | list) -%}
    
    {%- set routines_in_scope_sql -%}
    SELECT
        specific_catalog || '.' || specific_schema || '.' || specific_name routine_ref
    FROM `{{ target.database }}.region-{{ target.location }}`.INFORMATION_SCHEMA.ROUTINES
    WHERE (specific_schema = '{{ target.schema }}' OR specific_schema LIKE '{{ target.schema }}_%')
    {%- endset -%}

    {%- set routines_in_scope = run_query(routines_in_scope_sql).columns[0].values() -%}

    {%- set routines_to_drop_sql -%}
        {%- for routine_ref in routines_in_scope -%}
            {%- if routine_ref not in active_udf_refs %}
                DROP FUNCTION `{{ routine_ref }}`;
            {% endif -%}
        {%- endfor -%}
    {%- endset -%}

   
    {{ return(routines_to_drop_sql) }}
    
{%- endmacro -%}

{%- macro drop_orphaned_relations_of_type(materialized, bq_type, schemas_in_scope) -%}
    {%- set relations_in_scope_sql -%}
        {%- for schema_name in schemas_in_scope %}
        SELECT
            table_catalog || '.' || table_schema || '.' || table_name relation_ref
        FROM `{{ target.database }}.{{ schema_name }}.INFORMATION_SCHEMA.TABLES`
        WHERE table_type = '{{ bq_type }}'
        {{ ' UNION ALL ' if not loop.last }} 
        {% endfor -%}
    {%- endset -%}

    {%- set relations_in_scope = run_query(relations_in_scope_sql).columns[0].values() -%}


    {%- set active_nodes = graph.nodes.values()
        | selectattr('resource_type', 'in', ['model', 'seed'])
        | list -%}
    
    {%- set active_sources = graph.sources.values() | list -%}
    
    {%- set active_relation_refs = nodes_to_bq_refs(active_nodes + active_sources) -%}

    {%- set relations_to_drop_sql -%}
        {%- for relation_ref in relations_in_scope -%}
            {%- if relation_ref not in active_relation_refs %}
                DROP {{ materialized }} `{{ relation_ref }}`;
            {% endif -%}
        {%- endfor -%}
    {%- endset -%}

    {{ return(relations_to_drop_sql) }}

{%- endmacro -%}

{%- macro cleanup(dry_run=True) -%}
{%- set is_dry_run = dry_run | as_bool -%}
{%- if execute -%}
    {%- set schemas_in_scope_sql -%}
    SELECT
        schema_name
    FROM `{{ target.database }}.region-{{ target.location }}`.INFORMATION_SCHEMA.SCHEMATA
    WHERE (schema_name = '{{ target.schema }}' OR schema_name LIKE '{{ target.schema }}_%')
    {%- endset -%}
    {%- set schemas_in_scope = run_query(schemas_in_scope_sql).columns[0].values() -%}
    
    {%- set drop_udf_sql = drop_orphaned_udfs() -%}
    {%- set drop_views_sql = drop_orphaned_relations_of_type(materialized='view', bq_type='VIEW', schemas_in_scope=schemas_in_scope) -%}
    {%- set drop_tables_sql = drop_orphaned_relations_of_type(materialized='table', bq_type='BASE TABLE', schemas_in_scope=schemas_in_scope) -%}

    {%- if is_dry_run -%}
        {%- do log('Cleanup - dry run') -%}
        {%- do log('Cleanup - udfs: ' ~ drop_udf_sql) -%}
        {%- do log('Cleanup - views: ' ~ drop_views_sql) -%}
        {%- do log('Cleanup - tables: ' ~ drop_tables_sql) -%}
    {%- else -%}
        {%- call statement('cleanup - udfs') -%}
            SELECT 1;
            {{ drop_udf_sql }}
        {%- endcall -%}
        {%- call statement('cleanup - views') -%}
            SELECT 1;
            {{ drop_views_sql }}
        {%- endcall -%}
        {%- call statement('cleanup - tables') -%}
            SELECT 1;
            {{ drop_tables_sql }}
        {%- endcall -%}
    {%- endif -%}

{%- endif -%}
{%- endmacro -%}

