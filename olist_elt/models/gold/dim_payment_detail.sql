SELECT
    ROW_NUMBER() OVER () AS dim_payment_detail_id,
    nro_instance,
    payment_type
FROM {{ ref('stg_payment_detail') }}