#!/usr/bin/env python3
"""Validate append-only Work Logs and require one for Jira-key branches."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKLOG_DIR = ROOT / ".agent" / "worklogs"
ALLOWED_FIELDS = {
    "time", "type", "summary", "evidence", "result", "reason", "verification",
    "branch", "domain", "workType", "owner", "notionUrl", "mrUrl",
}
ALLOWED_TYPES = {
    "START", "ERROR", "ATTEMPT", "DECISION", "ROOT_CAUSE", "SOLUTION",
    "VERIFICATION", "BLOCKED", "FINISH",
}
SECRET_PATTERN = re.compile(
    r"(?i)(api[_-]?key|client[_-]?secret|access[_-]?token|refresh[_-]?token|password)\s*[:=]|bearer\s+[a-z0-9._-]+"
)
BRANCH_PATTERN = re.compile(
    r"^(feat|fix|refactor|test|docs|infra|chore|perf|security)/((?:ATH|LOCAL)-[0-9]+)-[a-z0-9]+(?:-[a-z0-9]+)*$"
)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")


def current_branch() -> str:
    result = subprocess.run(
        ["git", "branch", "--show-current"], cwd=ROOT, capture_output=True, text=True, check=False
    )
    return result.stdout.strip()


def validate_file(path: Path) -> list[str]:
    errors: list[str] = []
    events: list[dict[str, object]] = []
    for line_number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError as error:
            errors.append(f"{path.name}:{line_number} JSON 오류: {error.msg}")
            continue
        if not isinstance(event, dict):
            errors.append(f"{path.name}:{line_number} 객체가 아닙니다.")
            continue
        missing = {"time", "type", "summary"} - event.keys()
        unknown = event.keys() - ALLOWED_FIELDS
        if missing:
            errors.append(f"{path.name}:{line_number} 필수 필드 누락: {sorted(missing)}")
        if unknown:
            errors.append(f"{path.name}:{line_number} 허용되지 않은 필드: {sorted(unknown)}")
        if event.get("type") not in ALLOWED_TYPES:
            errors.append(f"{path.name}:{line_number} 알 수 없는 type: {event.get('type')}")
        if not isinstance(event.get("summary"), str) or not event.get("summary", "").strip():
            errors.append(f"{path.name}:{line_number} summary가 비어 있습니다.")
        if SECRET_PATTERN.search(raw_line):
            errors.append(f"{path.name}:{line_number} Secret 의심 내용이 있습니다.")
        events.append(event)
    if events and events[0].get("type") != "START":
        errors.append(f"{path.name}: 첫 이벤트는 START여야 합니다.")
    finish_events = [event for event in events if event.get("type") == "FINISH"]
    if finish_events and not finish_events[-1].get("verification"):
        errors.append(f"{path.name}: FINISH에는 verification이 필요합니다.")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--branch", default="")
    args = parser.parse_args()
    branch = args.branch or current_branch()
    errors: list[str] = []

    match = BRANCH_PATTERN.fullmatch(branch)
    if branch not in {"main", "dev", ""} and not match:
        errors.append(f"브랜치 형식 오류: {branch}")
    if match and not (WORKLOG_DIR / f"{match.group(2)}.jsonl").exists():
        errors.append(f"{match.group(2)} Work Log가 없습니다.")

    for path in sorted(WORKLOG_DIR.glob("*.jsonl")):
        errors.extend(validate_file(path))

    if errors:
        for error in errors:
            print(f"[FAIL] {error}")
        return 1
    print("[PASS] 브랜치와 Work Log 검증 통과")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
