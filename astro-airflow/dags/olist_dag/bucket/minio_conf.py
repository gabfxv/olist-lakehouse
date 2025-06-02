def get_minio_client():
    from minio import Minio
    from airflow.hooks.base import BaseHook

    conn = BaseHook.get_connection("minio_conn")

    client = Minio(
        f'{conn.host}:{conn.port}',
        access_key=conn.login,
        secret_key=conn.password,
        secure=False
    )
    return client