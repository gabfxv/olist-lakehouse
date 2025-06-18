SELECT
    ROW_NUMBER() OVER () AS dim_comment_id,
    title,
    message
FROM {{ ref('stg_comment') }}