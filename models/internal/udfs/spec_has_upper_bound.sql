
{{ config(
    materialized='udf',
    parameter_list='spec STRING',
    returns='BOOL',
    description='True if the version specification has an upper bound, i.e. "<1.2", ">1.0,<1.2", "==0.54"'
) }}

spec LIKE '==%' OR spec like '%<%'

