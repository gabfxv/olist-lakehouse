{{ config(
    materialized='incremental',
    unique_key=['title', 'message'],
    incremental_strategy='merge'
) }}


WITH ranked_comments AS (
    SELECT
        title,
        message,
        capture_timestamp,
        ROW_NUMBER() OVER (PARTITION BY title, message ORDER BY capture_timestamp DESC) AS rn
    FROM {{ ref('stg_review') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
)

SELECT title, message, capture_timestamp
FROM ranked_comments
WHERE rn = 1