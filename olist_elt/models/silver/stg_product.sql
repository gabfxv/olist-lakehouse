{{ config(
    materialized='incremental',
    unique_key='dim_product_category_id',
    incremental_strategy='merge'
) }}

SELECT
    dim_product_category_id,
    product_name_lenght AS name_length,
    product_description_lenght AS description_length,
    product_photos_qty AS photos_qty,
    product_weight_g AS weight_g,
    product_length_cm AS length_cm,
    product_height_cm AS height_cm,
    product_width_cm AS width_cm,
    product_id,
    capture_timestamp
FROM {{ source('bronze', 'product') }} p
JOIN {{ ref('dim_product_category') }} c
    ON p.product_category_name = c.name_pt
{% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
{% endif %}
