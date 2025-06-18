SELECT
    ROW_NUMBER() OVER () AS dim_time_id,
    full_time,
    hour,
    minute,
    second,
    time_bucket
FROM {{ ref('stg_time') }}