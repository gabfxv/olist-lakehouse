{{ config(
    materialized='incremental',
    unique_key='full_time',
    incremental_strategy='merge'
) }}

WITH time_components AS (
    SELECT
        full_time,
        capture_timestamp,
        EXTRACT(HOUR FROM full_time) AS hour,
        EXTRACT(MINUTE FROM full_time) AS minute,
        EXTRACT(SECOND FROM full_time) AS second
    FROM {{ ref('int_time__union') }}
    {% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
)

SELECT
    full_time,
    hour,
    minute,
    second,
    capture_timestamp,
    CASE
        WHEN hour IS NULL THEN 'Sem horário'
        WHEN hour BETWEEN 6 AND 11 THEN 'Manhã'
        WHEN hour BETWEEN 12 AND 17 THEN 'Tarde'
        WHEN hour BETWEEN 18 AND 23 THEN 'Noite'
        ELSE 'Madrugada'
    END AS time_bucket
FROM time_components