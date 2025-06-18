{{ config(
    materialized='incremental',
    unique_key='full_date',
    incremental_strategy='merge'
) }}

WITH all_dates AS (
    SELECT purchase_dt AS full_date, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT approval_dt AS full_date, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT carrier_dt AS full_date, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT customer_delivery_dt AS full_date, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT estimated_delivery_dt AS full_date, capture_timestamp FROM {{ ref('stg_order') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT shipping_limit_dt AS full_date, capture_timestamp FROM {{ ref('stg_order_item') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT answer_dt AS full_date, capture_timestamp FROM {{ ref('stg_review') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
    UNION ALL
    SELECT creation_dt AS full_date, capture_timestamp FROM {{ ref('stg_review') }}
        {% if is_incremental() %} WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})  {% endif %}
),

ranked_dates AS (
    SELECT
        full_date,
        capture_timestamp,
        ROW_NUMBER() OVER (PARTITION BY full_date ORDER BY capture_timestamp DESC) AS rn
    FROM all_dates
)

SELECT full_date, capture_timestamp
FROM ranked_dates
WHERE rn = 1

UNION ALL

SELECT NULL AS full_date, NULL AS capture_timestamp