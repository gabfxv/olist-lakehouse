SELECT
    o.dim_order_id,
    c.dim_comment_id,
    cd.dim_date_id AS dim_creation_dt_id,
    t.dim_time_id AS dim_answer_ts_id,
    ad.dim_date_id AS dim_answer_dt_id,
    r.review_score,
    r.review_id
FROM {{ ref('stg_review') }} r
JOIN {{ ref('dim_order') }} o
    ON r.order_id = o.order_id
JOIN {{ ref('dim_comment') }} c
    ON r.title = c.title
    AND r.message = c.message
JOIN {{ ref('dim_time') }} t
    ON r.answer_ts = t.full_time
JOIN {{ ref('dim_date') }} cd
    ON r.creation_dt = cd.full_date
JOIN {{ ref('dim_date') }} ad
    ON r.answer_dt = ad.full_date