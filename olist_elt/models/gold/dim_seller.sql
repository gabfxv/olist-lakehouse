SELECT
    ROW_NUMBER() OVER () AS dim_seller_id,
    l.dim_location_id,
    s.seller_id
FROM {{ ref('stg_seller') }} s
JOIN {{ ref('dim_location') }} l
    ON s.zip_code_prefix = l.zip_code_prefix
    AND s.city = l.city
    AND s.state = l.state