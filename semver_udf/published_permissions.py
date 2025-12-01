import json
import pathlib

from google.cloud import bigquery

def is_duplicate_dataset_access_entry(e1, e2):
    def get_comparable(entry):
        return json.dumps(entry.to_api_repr().get('dataset'), sort_keys=True)
         
    return get_comparable(e1) == get_comparable(e2)

if __name__ == '__main__':
    manifest_path = pathlib.Path.cwd() / 'target' / 'manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    databases = set()
    schemas = set()
    for node in manifest['nodes'].values():
        if node['resource_type'] == 'model':
            schemas.add(node['schema'])
            databases.add(node['database'])
    
    if len(databases) != 1:
        raise ValueError("Multiple databases found in manifest. This script supports only one database.")

    project_id = list(databases)[0]
    published_schemas = {schema for schema in schemas if not schema.endswith('_impl')}
    impl_schemas = schemas.difference(published_schemas)

    client = bigquery.Client()

    dataset_access_entries = [
        bigquery.AccessEntry(
            entity_type='dataset',
            entity_id={
                'dataset': {
                    'projectId': project_id,
                    'datasetId': schema
                },
                'targetTypes': ['VIEWS']
            }
        )
        for schema in published_schemas
    ]


    for schema in impl_schemas:
        dataset = client.get_dataset(schema)
        current_access_entries = dataset.access_entries
        final_access_entries = current_access_entries.copy()

        for published_entry in dataset_access_entries:
            is_duplicate = False
            for current_entry in current_access_entries:
                if is_duplicate_dataset_access_entry(current_entry, published_entry):
                    is_duplicate = True
                    break
            if not is_duplicate:
                print(f'Adding new access entry to dataset {schema}: {published_entry}')
                final_access_entries.append(published_entry)

        dataset.access_entries = final_access_entries
        
        client.update_dataset(dataset, ['access_entries'])
        