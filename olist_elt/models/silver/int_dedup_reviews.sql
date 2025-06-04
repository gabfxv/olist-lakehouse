{{ dbt_utils.deduplicate(
    relation=source('bronze', 'reviews'),
    partition_by='review_id',
    order_by="review_score desc"
   )
}}