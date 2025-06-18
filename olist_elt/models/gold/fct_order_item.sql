SELECT
    o.dim_order_id,
    oi.dim_order_item_id,
    p.dim_product_id,
    s.dim_seller_id,
    t.dim_time_id AS dim_shipping_limit_ts_id,
    d.dim_date_id AS dim_shipping_limit_dt_id,
    price,
    freight_value
FROM {{ ref('stg_order_item') }} i
JOIN {{ ref('dim_order') }} o
    ON i.order_id = o.order_id
JOIN {{ ref('dim_order_item') }} oi
    ON i.order_item = oi.order_item
JOIN {{ ref('dim_product') }} p
    ON i.product_id = p.product_id
JOIN {{ ref('dim_seller') }} s
    ON i.seller_id = s.seller_id
JOIN {{ ref('dim_time') }} t
    ON i.shipping_limit_ts = t.full_time
JOIN {{ ref('dim_date') }} d
    ON i.shipping_limit_dt = d.full_date