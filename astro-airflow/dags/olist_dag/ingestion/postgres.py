from minio import Minio

def ingest_file_to_bronze(bucket_name: str, object_name: str, minio_client: Minio, engine):
    from pandas import read_csv, Timestamp
    from olist_dag.bucket.minio_conf import get_minio_client

    print(f"Adding {object_name} to database")
    response = minio_client.get_object(bucket_name, object_name)
    table_name = object_name.replace('.csv', '')
    chunksize = 4000

    capture_timestamp = Timestamp.now()

    print(f"Table bronze.{table_name} doesn't exist. Creating new table.")

    with response as stream:
        for i, chunk in enumerate(read_csv(stream, chunksize=chunksize)):
            chunk['capture_timestamp'] = capture_timestamp
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

    print(f"Data loaded to table {table_name}")


def ingest_staging_to_bronze(table_name, engine):
    from sqlalchemy.sql import text

    with engine.begin() as conn:
        check_table_sql = text(f"""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'staging' 
                AND table_name = '{table_name}'
            )
        """)

        table_exists = conn.execute(check_table_sql).scalar()

        if not table_exists:
            create_table_sql = text(f"""
                CREATE TABLE staging.{table_name} AS 
                SELECT * FROM bronze.{table_name} 
                WHERE 1=0
            """)
            conn.execute(create_table_sql)

            # Remove a coluna capture_timestamp da tabela staging (se existir)
            alter_table_sql = text(f"""
                ALTER TABLE staging.{table_name} 
                DROP COLUMN IF EXISTS capture_timestamp
            """)
            conn.execute(alter_table_sql)
            print(f"Tabela staging.{table_name} criada com sucesso.")

        insert_sql = text(f"""
            INSERT INTO bronze.{table_name}
            SELECT *, CURRENT_TIMESTAMP AS capture_timestamp FROM staging.{table_name}
        """)
        result = conn.execute(insert_sql)

        truncate_sql = text(f"TRUNCATE TABLE staging.{table_name}")
        conn.execute(truncate_sql)

        rows_inserted = result.rowcount
        print(
            f"Tabela {table_name}: {rows_inserted} registros transferidos de staging para bronze e staging limpa com sucesso.")