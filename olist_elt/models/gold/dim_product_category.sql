SELECT
    ROW_NUMBER() OVER () AS dim_product_category_id,
    product_category_name AS name_pt,
    product_category_name_english AS name_en
FROM {{ source('bronze', 'category_translation') }}