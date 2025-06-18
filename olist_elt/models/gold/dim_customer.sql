SELECT
    ROW_NUMBER() OVER () AS dim_customer_id,
    l.dim_location_id,
    c.customer_id,
    c.customer_unique_id
FROM {{ ref('stg_customer') }} c
JOIN {{ ref('dim_location') }} l
    ON c.zip_code_prefix = l.zip_code_prefix
    AND c.city = l.city
    AND c.state = l.state