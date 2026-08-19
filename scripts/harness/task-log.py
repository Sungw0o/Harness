#!/usr/bin/env python3
"""Append-only local Work Log lifecycle for Jira/Notion synchronization."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKLOG_DIR = ROOT / ".agent" / "worklogs"
KEY_PATTERN = re.compile(r"^(?:ATH|LOCAL)-[0-9]+$")

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")


def current_branch() -> str:
    result = subprocess.run(
        ["git", "branch", "--show-current"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.stdout.strip()


def validate_key(value: str) -> str:
    value = value.upper()
    if not KEY_PATTERN.fullmatch(value):
        raise argparse.ArgumentTypeError("작업 키는 LOCAL-숫자 또는 ATH-숫자 형식이어야 합니다.")
    return value


def append_event(jira_key: str, event: dict[str, str]) -> Path:
    WORKLOG_DIR.mkdir(parents=True, exist_ok=True)
    path = WORKLOG_DIR / f"{jira_key}.jsonl"
    payload = {
        "time": datetime.now().astimezone().isoformat(timespec="seconds"),
        **{key: value for key, value in event.items() if value},
    }
    with path.open("a", encoding="utf-8", newline="\n") as stream:
        stream.write(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n")
    return path


def command_start(args: argparse.Namespace) -> None:
    path = WORKLOG_DIR / f"{args.jira_key}.jsonl"
    if path.exists() and path.stat().st_size:
        raise SystemExit(f"이미 Work Log가 존재합니다: {path.relative_to(ROOT)}")
    created = append_event(
        args.jira_key,
        {
            "type": "START",
            "summary": args.title,
            "branch": args.branch or current_branch(),
            "domain": args.domain,
            "workType": args.work_type,
            "owner": args.owner,
            "notionUrl": args.notion_url,
        },
    )
    print(f"Work Log 시작: {created.relative_to(ROOT)}")


def command_checkpoint(args: argparse.Namespace) -> None:
    path = WORKLOG_DIR / f"{args.jira_key}.jsonl"
    if not path.exists():
        raise SystemExit("먼저 start 명령으로 Work Log를 생성하세요.")
    append_event(
        args.jira_key,
        {
            "type": args.event_type,
            "summary": args.summary,
            "evidence": args.evidence,
            "result": args.result,
            "reason": args.reason,
        },
    )
    print(f"체크포인트 기록: {path.relative_to(ROOT)}")


def command_finish(args: argparse.Namespace) -> None:
    path = WORKLOG_DIR / f"{args.jira_key}.jsonl"
    if not path.exists():
        raise SystemExit("먼저 start 명령으로 Work Log를 생성하세요.")
    append_event(
        args.jira_key,
        {
            "type": "FINISH",
            "summary": args.summary,
            "verification": args.verification,
            "mrUrl": args.mr_url,
            "notionUrl": args.notion_url,
        },
    )
    print(f"Work Log 완료: {path.relative_to(ROOT)}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    start = subparsers.add_parser("start")
    start.add_argument("jira_key", type=validate_key)
    start.add_argument("title")
    start.add_argument("--branch", default="")
    start.add_argument("--domain", default="")
    start.add_argument("--work-type", default="")
    start.add_argument("--owner", default="")
    start.add_argument("--notion-url", default="")
    start.set_defaults(handler=command_start)

    checkpoint = subparsers.add_parser("checkpoint")
    checkpoint.add_argument("jira_key", type=validate_key)
    checkpoint.add_argument(
        "event_type",
        choices=["ERROR", "ATTEMPT", "DECISION", "ROOT_CAUSE", "SOLUTION", "VERIFICATION", "BLOCKED"],
    )
    checkpoint.add_argument("summary")
    checkpoint.add_argument("--evidence", default="")
    checkpoint.add_argument("--result", default="")
    checkpoint.add_argument("--reason", default="")
    checkpoint.set_defaults(handler=command_checkpoint)

    finish = subparsers.add_parser("finish")
    finish.add_argument("jira_key", type=validate_key)
    finish.add_argument("summary")
    finish.add_argument("--verification", required=True)
    finish.add_argument("--mr-url", default="")
    finish.add_argument("--notion-url", default="")
    finish.set_defaults(handler=command_finish)
    return parser


if __name__ == "__main__":
    parsed = build_parser().parse_args()
    parsed.handler(parsed)
