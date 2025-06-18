{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='merge'
) }}

SELECT
    order_id,
    customer_id,
    order_status AS status,
    order_purchase_timestamp::time AS purchase_ts,
    order_purchase_timestamp::date AS purchase_dt,
    order_approved_at::time AS approval_ts,
    order_approved_at::date AS approval_dt,
    order_delivered_carrier_date::time AS carrier_ts,
    order_delivered_carrier_date::date AS carrier_dt,
    order_delivered_customer_date::time AS customer_delivery_ts,
    order_delivered_customer_date::date AS customer_delivery_dt,
    order_estimated_delivery_date::date AS estimated_delivery_dt,
    capture_timestamp
FROM {{ source('bronze', 'order') }}
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}