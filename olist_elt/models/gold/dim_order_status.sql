SELECT
    ROW_NUMBER() OVER () AS dim_order_status_id,
    status,
    description
FROM {{ ref('order_status') }}