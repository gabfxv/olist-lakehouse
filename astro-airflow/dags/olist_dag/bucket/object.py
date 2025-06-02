def add_object(bucket_name: str, object_name: str, object_path: str):
    import os
    from olist_dag.bucket.minio_conf import get_minio_client
    from olist_dag.bucket.bucket import create_bucket
    from minio import S3Error

    client = get_minio_client()

    if not os.path.isfile(object_path):
        raise FileNotFoundError(f"O arquivo '{object_path}' não foi encontrado.")

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
            f"Arquivo '{object_path}' enviado como '{object_name}' para o bucket '{bucket_name}'."
        )
    except S3Error as e:
        print("Erro ao fazer upload para o MinIO:", e)