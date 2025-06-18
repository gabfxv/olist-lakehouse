{{ config(
    materialized='incremental',
    unique_key='review_id',
    incremental_strategy='merge'
) }}

WITH review_ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY capture_timestamp DESC) AS row_num
    FROM {{ source('bronze', 'review') }}
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title AS title,
    review_comment_message AS message,
    review_creation_date::date AS creation_dt,
    review_answer_timestamp::time AS answer_ts,
    review_answer_timestamp::date AS answer_dt,
    capture_timestamp
FROM review_ranked
WHERE row_num = 1
{% if is_incremental() %}
    AND capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}