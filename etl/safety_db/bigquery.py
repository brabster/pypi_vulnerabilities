from google.cloud import bigquery

SAFETY_HISTORY_TIME_PARTITIONING = bigquery.TimePartitioning(
    type_=bigquery.TimePartitioningType.DAY
)


def get_client(project_id: str, location: str) -> bigquery.Client:
    return bigquery.Client(project=project_id, location=location)


def ensure_dataset_exists(bq: bigquery.Client, dataset_name: str) -> bigquery.Dataset:
    return bq.create_dataset(dataset=dataset_name, exists_ok=True)


def existing_partition_dates(bq, table: bigquery.Table) -> set[str]:
    partition_result = bq.query(
        f"""
SELECT
  CAST(partition_id AS TIMESTAMP FORMAT 'YYYYMMDD' AT TIME ZONE 'UTC') partition_date
FROM {table.dataset_id}.INFORMATION_SCHEMA.PARTITIONS
WHERE table_catalog = '{table.project}'
  AND table_schema = '{table.dataset_id}'
  AND table_name = '{table.table_id}'
"""
    ).result()
    return {row["partition_date"].date() for row in partition_result}


def create_partitioned_table_if_not_exists(
    bq: bigquery.Client, table_ref: str, schema
) -> bigquery.Table:
    table = bigquery.Table(table_ref, schema=schema)
    table.time_partitioning = SAFETY_HISTORY_TIME_PARTITIONING
    return bq.create_table(table, exists_ok=True)


def load_partition(bq, history_table, partition_date, schema, json_rows):
    destination = f'{history_table}${partition_date.strftime("%Y%m%d")}'
    job = bq.load_table_from_json(
        json_rows=json_rows,
        destination=destination,
        job_config=bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
            write_disposition="WRITE_TRUNCATE",
            time_partitioning=SAFETY_HISTORY_TIME_PARTITIONING,
            schema=schema,
        ),
    )
    job.result()
    print(f"Loaded table partition {destination}, {job}, {job.result()}")
