from airflow.decorators import task

@task
def create_bucket(bucket_name: str):
    from olist_dag.bucket.minio_conf import get_minio_client
    client = get_minio_client()

    if not client.bucket_exists(bucket_name):
        client.make_bucket(bucket_name)
        print(f"Bucket '{bucket_name}' successfully created!")
    else:
        print(f"Bucket '{bucket_name}' already exists.")