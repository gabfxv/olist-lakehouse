{{ config(
    materialized='incremental',
    unique_key=['order_id', 'order_item'],
    incremental_strategy='merge'
) }}

SELECT
    order_id,
    order_item_id AS order_item,
    product_id,
    seller_id,
    shipping_limit_date::date AS shipping_limit_dt,
    shipping_limit_date::time AS shipping_limit_ts,
    price,
    freight_value,
    capture_timestamp
FROM {{ source('bronze', 'order_item') }}
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}
