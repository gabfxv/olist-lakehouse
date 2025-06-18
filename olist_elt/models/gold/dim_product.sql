SELECT
    ROW_NUMBER() OVER () AS dim_product_id,
    dim_product_category_id,
    name_length,
    description_length,
    photos_qty,
    weight_g,
    length_cm,
    height_cm,
    width_cm,
    product_id
FROM {{ ref('stg_product') }}
