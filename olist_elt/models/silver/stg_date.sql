{{ config(
    materialized='incremental',
    unique_key='full_date',
    incremental_strategy='merge'
) }}

WITH date_components AS (
    SELECT
        full_date,
        EXTRACT(DAY FROM full_date) AS day,
        EXTRACT(DOW FROM full_date)::int AS day_week,
        EXTRACT(MONTH FROM full_date) AS month,
        EXTRACT(YEAR FROM full_date) AS year,
        CEIL(EXTRACT(MONTH FROM full_date) / 3.0) AS trimester,
        CEIL(EXTRACT(MONTH FROM full_date) / 6.0) AS semester,
        (FLOOR(EXTRACT(YEAR FROM full_date) / 10) * 10)::int AS decade,
        capture_timestamp
    FROM {{ ref('int_date__union') }}
    {% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    d.full_date,
    d.day,
    d.day_week,
    w.day_week_written_pt,
    d.month,
    m.month_written_pt,
    d.trimester,
    d.semester,
    d.year,
    d.decade,
    d.capture_timestamp
FROM date_components d
JOIN {{ ref('month') }} m
    ON d.month = m.month
JOIN {{ ref('day_week') }} w
    ON d.day_week = w.day_week