{{ config(
    materialized='incremental',
    unique_key='full_time',
    incremental_strategy='merge'
) }}

WITH all_times AS (
    SELECT purchase_ts AS full_time, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT approval_ts AS full_time, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT carrier_ts AS full_time, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT customer_delivery_ts AS full_time, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT shipping_limit_ts AS full_time, capture_timestamp FROM {{ ref('stg_order_item') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT answer_ts AS full_time, capture_timestamp FROM {{ ref('stg_review') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
),

ranked_times AS (
    SELECT
        full_time,
        capture_timestamp,
        ROW_NUMBER() OVER (PARTITION BY full_time ORDER BY capture_timestamp DESC) AS rn
    FROM all_times
)

SELECT full_time, capture_timestamp
FROM ranked_times
WHERE rn = 1