import json
import os
import urllib.request

SAFETY_DB_URL_2023_10_01 = "https://raw.githubusercontent.com/pyupio/safety-db/38e18cd9f27b02c733aa9ece1399ef61e28fc7e3/data/insecure_full.json"
TARGET_PATH = os.path.join(
    os.path.dirname(__file__), "../uncommitted", "safety_db_2023_10_01.jsonl"
)

if __name__ == "__main__":
    with urllib.request.urlopen(SAFETY_DB_URL_2023_10_01) as instream:
        safety_json = json.loads(instream.read().decode("utf-8"))

    safety_rows = (
        {"package": k, "commit_date": "2023-10-01", "vulnerabilities": v}
        for k, v in safety_json.items()
        if k != "$meta"
    )

    print(f"Writing safety_db to {TARGET_PATH}")
    with open(TARGET_PATH, "w") as outstream:
        for row in safety_rows:
            outstream.write(json.dumps(row) + "\n")
