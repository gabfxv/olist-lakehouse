SELECT
    ROW_NUMBER() OVER () AS dim_date_id,
    full_date,
    day,
    day_week,
    day_week_written_pt,
    month,
    month_written_pt,
    trimester,
    semester,
    year,
    decade
FROM {{ ref('stg_date') }}