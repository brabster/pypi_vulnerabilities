import json
import urllib.request
import os

SAFETY_DB_URL = 'https://raw.githubusercontent.com/pyupio/safety-db/master/data/insecure_full.json'
TARGET_PATH = os.path.join(os.path.dirname(__file__), '../uncommitted', 'safety_db.jsonl')

if __name__ == '__main__':
    with urllib.request.urlopen(SAFETY_DB_URL) as instream:
        safety_json = json.loads(instream.read().decode('utf-8'))
        
    safety_rows = ({'package': k, 'vulnerabilities': v} for k, v in safety_json.items() if k != '$meta')
        
    print(f'Writing safety_db to {TARGET_PATH}')
    with open(TARGET_PATH, 'w') as outstream:
        for row in safety_rows:
            outstream.write(json.dumps(row) + '\n')
        
