import datetime
from airflow.sdk import DAG,task
import time


with DAG(
    dag_id="example_dag",
    start_date=datetime.datetime(2024, 6, 1),
    schedule_interval="@daily",
):
    @task
    def hello_world():
        time.sleep(5)
        print("Hello, World! from Airflow")

    hello_world()



