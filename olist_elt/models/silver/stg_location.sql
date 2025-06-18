SELECT
    u.zip_code_prefix,
    d.lat,
    d.long,
    u.city,
    u.state,
    GREATEST(u.capture_timestamp, d.capture_timestamp) AS capture_timestamp,
    'Brasil' AS country,
    'América' AS continent
FROM {{ ref('int_location__union') }} u
LEFT JOIN {{ ref('int_location__dedup') }} d
    ON u.zip_code_prefix = d.zip_code_prefix
    AND u.city = d.city
    AND u.state = d.state