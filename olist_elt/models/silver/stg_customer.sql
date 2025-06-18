{{ config(
    materialized='incremental',
    unique_key='customer_unique_id'
) }}

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix AS zip_code_prefix,
    customer_city AS city,
    customer_state AS state,
    capture_timestamp
FROM {{ source('bronze', 'customer') }}
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}