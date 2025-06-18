{{ config(
    materialized='incremental',
    unique_key=['nro_instance', 'payment_type'],
    incremental_strategy='merge'
) }}

WITH ranked_payment_detail AS (
    SELECT
        nro_instance,
        payment_type,
        capture_timestamp,
        ROW_NUMBER() OVER (PARTITION BY nro_instance, payment_type ORDER BY capture_timestamp DESC) AS rn
    FROM {{ ref('stg_payment') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
)

SELECT nro_instance, payment_type, capture_timestamp
FROM ranked_payment_detail
WHERE rn = 1
