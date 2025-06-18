{{ config(
    materialized='incremental',
    unique_key='order_item',
    incremental_strategy='merge'
) }}

WITH ranked_order_item AS (
    SELECT
        order_item,
        capture_timestamp,
        ROW_NUMBER() OVER (PARTITION BY order_item ORDER BY capture_timestamp DESC) AS rn
    FROM {{ ref('stg_order_item') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
)

SELECT order_item, capture_timestamp
FROM ranked_order_item
WHERE rn = 1
