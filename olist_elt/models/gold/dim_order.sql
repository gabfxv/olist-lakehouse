SELECT
    ROW_NUMBER() OVER () AS dim_order_id,
    c.dim_customer_id,
    s.dim_order_status_id,
    tp.dim_time_id AS purchase_ts_id,
    ta.dim_time_id AS approved_ts_id,
    tc.dim_time_id AS delivered_carrier_ts_id,
    tcd.dim_time_id AS delivered_customer_ts_id,
    dp.dim_date_id AS purchase_dt_id,
    da.dim_date_id AS approved_dt_id,
    dc.dim_date_id AS delivered_carrier_dt_id,
    dcd.dim_date_id AS delivered_customer_dt_id,
    ded.dim_date_id AS estimated_delivery_dt_id,
    o.order_id
FROM {{ ref('stg_order') }} o
JOIN {{ ref('dim_customer') }} c
    ON o.customer_id = c.customer_id
JOIN {{ ref('dim_order_status') }} s
    ON o.status = s.status
JOIN {{ ref('dim_time') }} tp
    ON o.purchase_ts = tp.full_time
JOIN {{ ref('dim_time') }} ta
    ON o.approval_ts = ta.full_time
JOIN {{ ref('dim_time') }} tc
    ON o.carrier_ts = tc.full_time
JOIN {{ ref('dim_time') }} tcd
    ON o.customer_delivery_ts = tcd.full_time
JOIN {{ ref('dim_date') }} dp
    ON o.purchase_dt = dp.full_date
JOIN {{ ref('dim_date') }} da
    ON o.approval_dt = da.full_date
JOIN {{ ref('dim_date') }} dc
    ON o.carrier_dt = dc.full_date
JOIN {{ ref('dim_date') }} dcd
    ON o.customer_delivery_dt = dcd.full_date
JOIN {{ ref('dim_date') }} ded
    ON o.estimated_delivery_dt = ded.full_date