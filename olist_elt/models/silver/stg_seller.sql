{{ config(
    materialized='incremental',
    unique_key='seller_id'
) }}

SELECT
    seller_id,
    seller_zip_code_prefix AS zip_code_prefix,
    seller_city AS city,
    seller_state AS state,
    capture_timestamp
FROM {{ source('bronze', 'seller') }}
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}
