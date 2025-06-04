def add_object(bucket_name: str, object_name: str, object_path: str):
    import os
    from olist_dag.bucket.minio_conf import get_minio_client
    from olist_dag.bucket.bucket import create_bucket
    from minio import S3Error

    client = get_minio_client()

    if not os.path.isfile(object_path):
        raise FileNotFoundError(f"The file '{object_path}' was not found.")

    found = client.bucket_exists(bucket_name)
    if not found:
        create_bucket(bucket_name)

    try:
        client.fput_object(
            bucket_name,
            object_name,
            object_path,
        )
        print(
            f"File '{object_path}' sent as '{object_name}' to bucket '{bucket_name}'."
        )
    except S3Error as e:
        print("Erro uploading to MinIO:", e)