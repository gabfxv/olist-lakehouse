{{ config(
    materialized='incremental',
    unique_key='zip_code_prefix',
    incremental_strategy='merge'
) }}

WITH base_data AS (
    SELECT *
    FROM {{ source('bronze', 'geolocation') }}
    {% if is_incremental() %}
    WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
),

lat_long_ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY geolocation_lat, geolocation_lng ORDER BY capture_timestamp DESC) AS row_num
    FROM base_data
),

lat_long_dedup AS (
    SELECT
        geolocation_zip_code_prefix AS zip_code_prefix,
        geolocation_lat AS lat,
        geolocation_lng AS long,
        unaccent(geolocation_city) AS city,
        geolocation_state AS state,
        capture_timestamp
    FROM lat_long_ranked
    WHERE row_num = 1
)

SELECT
    zip_code_prefix,
    AVG(lat) AS lat,
    AVG(long) AS long,
    MAX(city) AS city,
    MAX(state) AS state,
    MAX(capture_timestamp) AS capture_timestamp
FROM lat_long_dedup
GROUP BY zip_code_prefix