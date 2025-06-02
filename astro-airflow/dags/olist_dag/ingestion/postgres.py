from minio import Minio

def ingest_file_to_bronze(bucket_name: str, object_name: str, minio_client: Minio, engine):
    from pandas import read_csv
    from olist_dag.bucket.minio_conf import get_minio_client

    print(f"Adding {object_name} to database")

    response = minio_client.get_object(bucket_name, object_name)

    table_name = object_name.replace('.csv', '')

    chunksize = 4000

    with response as stream:
        for i, chunk in enumerate(read_csv(stream, chunksize=chunksize)):
            print(f"Inserting chunk {i} into {table_name}")
            chunk.to_sql(
                table_name,
                engine,
                schema='bronze',
                if_exists='replace' if i == 0 else 'append',
                index=False,
                method='multi'
            )

    response.release_conn()

    print(f"Dados carregados para tabela {table_name}")