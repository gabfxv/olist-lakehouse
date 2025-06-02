from airflow import DAG
from datetime import datetime
from olist_dag.bucket.tasks import create_bucket
from olist_dag.ingestion.tasks import ingest_files_to_data_lake
from olist_dag.ingestion.tasks import ingest_files_to_data_lake, list_csv_files, load_to_bronze

BUCKET_NAME = 'olist-bucket'
KAGGLE_DATASET = 'olistbr/brazilian-ecommerce'

with DAG(
    dag_id="minio_create_bucket",
    start_date=datetime(2024, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["bucket"],
) as dag:
    create_bucket_task = create_bucket(BUCKET_NAME)
    ingest_data_lake_task = ingest_files_to_data_lake(KAGGLE_DATASET, BUCKET_NAME)
    csv_files_list = list_csv_files(BUCKET_NAME)
    load_to_bronze_task = load_to_bronze.partial(bucket_name=BUCKET_NAME).expand(object_name=csv_files_list)

    create_bucket_task >> ingest_data_lake_task >> csv_files_list >> load_to_bronze_task