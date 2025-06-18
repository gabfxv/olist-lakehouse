SELECT
    ROW_NUMBER() OVER () AS dim_location_id,
    zip_code_prefix,
    lat,
    long,
    city,
    state,
    country,
    continent
FROM {{ ref('stg_location') }}