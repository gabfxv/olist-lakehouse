{{ config(
    materialized='incremental',
    unique_key='zip_code_prefix'
) }}

WITH unioned AS (
    SELECT
        zip_code_prefix,
        unaccent(city) AS city,
        state,
        2 AS src_priority,
        capture_timestamp
    FROM {{ ref('stg_seller') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}

    UNION ALL

    SELECT
        zip_code_prefix,
        unaccent(city) AS city,
        state,
        3 AS src_priority,
        capture_timestamp
    FROM {{ ref('stg_customer') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}

    UNION ALL

    SELECT
        zip_code_prefix,
        city,
        state,
        1 AS src_priority,
        capture_timestamp
    FROM {{ ref('int_location__dedup') }}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
),

ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY zip_code_prefix ORDER BY src_priority) AS row_num
    FROM unioned
)

SELECT
    zip_code_prefix,
    city,
    state,
    capture_timestamp
FROM ranked
WHERE row_num = 1