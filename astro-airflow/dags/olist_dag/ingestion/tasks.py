from airflow.decorators import task
from datetime import timedelta

@task
def ingest_files_to_data_lake(dataset: str, bucket_name: str):
    import os
    import tempfile
    import requests
    from zipfile import ZipFile
    from olist_dag.bucket.object import add_object
    url = f"https://www.kaggle.com/api/v1/datasets/download/{dataset}"

    zipfile = "dataset.zip"

    with tempfile.TemporaryDirectory() as tmp_dir:
        zip_path = os.path.join(tmp_dir, zipfile)

        response = requests.get(url, stream=True)
        response.raise_for_status()
        with open(zip_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        with ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(tmp_dir)

        for root, _, files in os.walk(tmp_dir):
            for file in files:
                if file == zipfile:
                    continue
                file_path = os.path.join(root, file)
                add_object(bucket_name, file, file_path)

@task
def list_csv_files(bucket_name: str):
    from olist_dag.bucket.minio_conf import get_minio_client

    client = get_minio_client()
    objects = client.list_objects(bucket_name, recursive=False)
    csv_files = [obj.object_name for obj in objects if obj.object_name.endswith('.csv')]
    print(f"CSV Files found: {csv_files}")
    return csv_files

@task(execution_timeout=timedelta(minutes=20))
def load_to_bronze(bucket_name: str, object_name: str):
    from olist_dag.bucket.minio_conf import get_minio_client
    from airflow.providers.postgres.hooks.postgres import PostgresHook
    from olist_dag.ingestion.postgres import ingest_file_to_bronze

    client = get_minio_client()
    hook = PostgresHook(postgres_conn_id='postgres_conn')
    engine = hook.get_sqlalchemy_engine()
    ingest_file_to_bronze(bucket_name, object_name, client, engine)