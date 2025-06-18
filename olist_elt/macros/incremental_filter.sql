{% macro incremental_filter() %}
    {% if is_incremental() %}
        WHERE capture_timestamp > (SELECT COALESCE(MAX(capture_timestamp), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
{% endmacro %}