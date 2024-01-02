from google.cloud import bigquery

import argparse
import os

SOURCE_PATH = os.path.join(os.path.dirname(__file__), '../uncommitted', 'safety_db_2022_07_01.jsonl')

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--project_id', default=os.environ.get('DBT_PROJECT'))
    parser.add_argument('--location', default=os.environ.get('DBT_LOCATION'))
    parser.add_argument('--dataset', default=os.environ.get('DBT_DATASET'))
    parser.add_argument('--table', default='safety_db_2022_07_01')
    parser.add_argument('--source_path', default=SOURCE_PATH)
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    table_id = f'{args.dataset}.{args.table}'
    client = bigquery.Client(
        project=args.project_id,
        location=args.location
    )

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        schema=client.schema_from_json(os.path.join(os.path.dirname(__file__), 'safety_schema.json')),
    )

    with open(args.source_path, 'rb') as source_file:
        job = client.load_table_from_file(source_file, table_id, job_config=job_config)
    
    job.result()
