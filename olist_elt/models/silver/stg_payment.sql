{{ config(
    materialized='incremental',
    unique_key=['order_id', 'nro_instance', 'payment_type'],
    incremental_strategy='merge'
) }}

SELECT
    order_id,
    payment_sequential AS nro_instance,
    payment_type,
    payment_installments AS nro_installments,
    payment_value,
    capture_timestamp
FROM {{ source('bronze', 'payment') }}
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}