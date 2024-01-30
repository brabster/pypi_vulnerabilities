from datetime import datetime
import json
import typing
import urllib.request

GITHUB_SAFETY_API_ROOT = "https://api.github.com/repos/pyupio/safety-db"
SAFETY_DB_FILE_PATH = "/data/insecure_full.json"
GITHUB_SAFETY_DB_COMMIT_LIST = (
    f"{GITHUB_SAFETY_API_ROOT}/commits?path={SAFETY_DB_FILE_PATH}"
)


class Commit(typing.NamedTuple):
    sha: str
    timestamp: str
    message: str
    file_url: str

    @staticmethod
    def from_safety_json(commit: dict):
        return Commit(
            sha=commit["sha"],
            timestamp=commit["commit"]["committer"]["date"],
            message=commit["commit"]["message"],
            file_url=f"https://raw.githubusercontent.com/pyupio/safety-db/{commit['sha']}{SAFETY_DB_FILE_PATH}",
        )

    def timestamp_date(self):
        return datetime.fromisoformat(self.timestamp).date()


def fetch_commit_list():
    with urllib.request.urlopen(GITHUB_SAFETY_DB_COMMIT_LIST) as instream:
        commits = json.loads(instream.read().decode("utf-8"))
        return [Commit.from_safety_json(commit) for commit in commits]


def fetch_commit_file_content(url):
    with urllib.request.urlopen(url) as instream:
        return json.loads(instream.read().decode("utf-8"))


def safety_to_jsonl(raw_content_json: dict, commit: Commit):
    return [
        {
            "commit": {
                x: commit._asdict()[x]
                for x in commit._asdict()
                if x not in ["timestamp"]
            },
            "commit_timestamp": commit.timestamp,
            "package": k,
            "vulnerabilities": v,
        }
        for k, v in raw_content_json.items()
        if k != "$meta"
    ]


def commits_except(existing_partition_dates: set[str], since: str) -> list[Commit]:
    return [
        commit
        for commit in fetch_commit_list()
        if commit.timestamp_date() not in existing_partition_dates
        and commit.timestamp > since
    ]


def fetch_commit_safety_content(commit: Commit) -> str:
    return safety_to_jsonl(fetch_commit_file_content(commit.file_url), commit)
