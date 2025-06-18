from airflow import DAG
from olist_dag.bucket.tasks import create_bucket
from airflow.utils.task_group import TaskGroup
from olist_dag.ingestion.tasks import ingest_files_to_data_lake, list_csv_files, ingest_data

from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig, RenderConfig
from cosmos.constants import ExecutionMode
from cosmos.profiles import PostgresUserPasswordProfileMapping
from pendulum import datetime
from airflow.operators.bash import BashOperator
from pathlib import Path
import os

BUCKET_NAME = 'olist-bucket'
KAGGLE_DATASET = 'olistbr/brazilian-ecommerce'

DBT_PROJECT_PATH = Path('/opt/dbt/project')
DBT_EXECUTABLE_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"

profile_config = ProfileConfig(
    profile_name="olist_elt",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id='postgres_conn',
        profile_args={
            "schema": "public",
        },
    ),
)

with DAG(
    dag_id="olist_pipeline",
    start_date=datetime(2025, 6, 7),
    schedule="@daily",
    catchup=False,
    tags=["bucket", "dbt", "lakehouse", "olist"],
) as dag:
    create_bucket_task = create_bucket(BUCKET_NAME)
    ingest_data_lake_task = ingest_files_to_data_lake(KAGGLE_DATASET, BUCKET_NAME)
    csv_files_list = list_csv_files(BUCKET_NAME)

    ingest_data_task = ingest_data.partial(
        bucket_name=BUCKET_NAME
    ).expand(object_name=csv_files_list)

    dbt_task = DbtTaskGroup(
        group_id="dbt_transform",
        project_config=ProjectConfig(
            manifest_path=DBT_PROJECT_PATH / "target" / "manifest.json",
            project_name="olist_elt",
        ),
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path=DBT_EXECUTABLE_PATH,
            dbt_project_path=DBT_PROJECT_PATH
        ),
        default_args={'retries': 2},
        render_config=RenderConfig(should_detach_multiple_parents_tests=True)
    )

    create_bucket_task >> ingest_data_lake_task >> csv_files_list >> ingest_data_task >> dbt_task