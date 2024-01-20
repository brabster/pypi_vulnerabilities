import json
import typing
import os
import urllib.request

GITHUB_SAFETY_API_ROOT = "https://api.github.com/repos/pyupio/safety-db"
SAFETY_DB_FILE_PATH = "/data/insecure_full.json"
GITHUB_SAFETY_DB_COMMIT_LIST = (
    f"{GITHUB_SAFETY_API_ROOT}/commits?path={SAFETY_DB_FILE_PATH}"
)

TARGET_PATH = os.path.join(os.path.dirname(__file__), "../uncommitted")


class Commit(typing.NamedTuple):
    sha: str
    timestamp: str
    message: str
    file_url: str


def fetch_commit_list():
    with urllib.request.urlopen(GITHUB_SAFETY_DB_COMMIT_LIST) as instream:
        commits = json.loads(instream.read().decode("utf-8"))
        return [
            Commit(
                sha=commit["sha"],
                timestamp=commit["commit"]["committer"]["date"],
                message=commit["commit"]["message"],
                file_url=f'https://raw.githubusercontent.com/pyupio/safety-db/{commit["sha"]}{SAFETY_DB_FILE_PATH}',
            )
            for commit in commits
        ]


def fetch_commit_file_content(url):
    with urllib.request.urlopen(url) as instream:
        return json.loads(instream.read().decode("utf-8"))


def safety_to_jsonl(raw_content_json: dict, commit: Commit):
    return [
        {
            "commit": commit._asdict(),
            "package": k,
            "vulnerabilities": v,
        }
        for k, v in raw_content_json.items()
        if k != "$meta"
    ]


if __name__ == "__main__":
    commits = fetch_commit_list()
    for commit in commits:
        json_content = fetch_commit_file_content(commit.file_url)
        content_jsonl = safety_to_jsonl(json_content, commit)
        output_path = os.path.join(TARGET_PATH, f'{commit.sha}.jsonl')

        print(f"Writing safety_db {commit.message} to {output_path}")
        with open(output_path, "w") as outstream:
            for row in content_jsonl:
                outstream.write(json.dumps(row) + "\n")
