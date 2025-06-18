SELECT
    ROW_NUMBER() OVER () AS dim_order_item_id,
    order_item
FROM
    {{ ref('stg_dim_order_item') }}