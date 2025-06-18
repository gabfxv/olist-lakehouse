SELECT
    o.dim_order_id,
    o.dim_customer_id,
    pd.dim_payment_detail_id,
    p.nro_installments,
    p.payment_value
FROM {{ ref('stg_payment') }} p
JOIN {{ ref('dim_order') }} o
    ON p.order_id = o.order_id
JOIN {{ ref('dim_payment_detail') }} pd
    ON p.payment_type = pd.payment_type
    AND p.nro_instance = pd.nro_instance