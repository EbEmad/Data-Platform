FROM apache/airflow:2.10.5-python3.11

COPY ./dags/ /opt/airflow/dags/

COPY ../requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

