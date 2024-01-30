import argparse
import os
import github
import bigquery

BASE_DIR = os.path.dirname(__file__)
UNCOMMITTED_PATH = os.path.join(BASE_DIR, "../uncommitted")


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--project_id", default=os.environ.get("DBT_PROJECT"))
    parser.add_argument("--location", default=os.environ.get("DBT_LOCATION"))
    parser.add_argument("--dataset", default=os.environ.get("DBT_DATASET"))
    parser.add_argument("--history_table", default="safety_db_history")
    parser.add_argument("--workdir", default=UNCOMMITTED_PATH)
    parser.add_argument("--commits_since", default="0")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    bq = bigquery.get_client(project_id=args.project_id, location=args.location)

    bigquery.ensure_dataset_exists(bq, args.dataset)
    
    history_table_schema = bq.schema_from_json(
        os.path.join(BASE_DIR, "safety_schema.json")
    )

    history_table_id = f"{args.project_id}.{args.dataset}.{args.history_table}"
    history_table = bigquery.create_partitioned_table_if_not_exists(
        bq=bq,
        table_ref=f"{args.project_id}.{args.dataset}.{args.history_table}",
        schema=history_table_schema,
    )

    existing_partition_dates = bigquery.existing_partition_dates(bq, history_table)
    print(f"Existing partitions ({len(existing_partition_dates)}):")
    for partition_date in reversed(sorted([pardate.isoformat() for pardate in existing_partition_dates])):
        print(partition_date)

    new_commits = github.commits_except(
        existing_partition_dates, since=args.commits_since
    )
    print(f"{len(new_commits)} new commits to load")

    for commit in new_commits:
        print(f"Loading commit {commit.sha} ({commit.timestamp})")
        commit_contents = github.fetch_commit_safety_content(commit)
        bigquery.load_partition(
            bq,
            history_table=history_table,
            partition_date=commit.timestamp_date(),
            schema=history_table_schema,
            json_rows=commit_contents,
        )
