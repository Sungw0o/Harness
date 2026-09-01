#!/usr/bin/env python3
"""Regression tests for the cross-platform harness contracts."""

from __future__ import annotations

import importlib.util
import os
import shutil
import subprocess
import sys
import unittest
from pathlib import Path

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[2]


def run(command: list[str], *, input_text: str = "", env: dict[str, str] | None = None) -> int:
    return subprocess.run(
        command,
        cwd=ROOT,
        input=input_text,
        text=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env=env,
        check=False,
    ).returncode


def find_sh() -> str:
    discovered = shutil.which("sh")
    if discovered:
        return discovered
    git = shutil.which("git")
    if git:
        candidate = Path(git).resolve().parents[1] / "bin" / "sh.exe"
        if candidate.exists():
            return str(candidate)
    raise unittest.SkipTest("POSIX shell을 찾지 못했습니다.")


def guard_commands() -> list[list[str]]:
    commands = [[find_sh(), ".harness/scripts/guard.sh"]]
    if os.name == "nt":
        commands.append([
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(ROOT / ".harness/scripts/guard.ps1"),
        ])
    return commands


def quick_check_command() -> list[str]:
    if os.name == "nt":
        return [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(ROOT / ".harness/scripts/quick-check.ps1"),
        ]
    return [find_sh(), ".harness/scripts/quick-check.sh"]


class GuardTests(unittest.TestCase):
    def test_sensitive_and_destructive_commands_are_blocked(self) -> None:
        commands = [
            "Get-Content .env; Write-Output done" if os.name == "nt" else "cat .env; echo done",
            "Get-Content config.pem; Write-Output done" if os.name == "nt" else "cat config.pem; echo done",
            "git clean -fd",
            "DROP TABLE users",
        ]
        commands.append(
            "Remove-Item -Recurse -Force C:\\tmp\\demo" if os.name == "nt" else "rm -rf ./demo"
        )
        for guard in guard_commands():
            for command in commands:
                with self.subTest(guard=guard[0], command=command):
                    self.assertEqual(2, run(guard, input_text=command))

    def test_safe_commands_are_allowed(self) -> None:
        commands = ["git status", "Get-Content .env.example" if os.name == "nt" else "cat .env.example"]
        for guard in guard_commands():
            for command in commands:
                with self.subTest(guard=guard[0], command=command):
                    self.assertEqual(0, run(guard, input_text=command))


class ConventionTests(unittest.TestCase):
    def test_branch_pattern_is_strict(self) -> None:
        shell = find_sh()
        for branch in ["dev", "feat/ATH-123-order-create", "fix/LOCAL-5-guard-validation"]:
            env = {**os.environ, "CI_COMMIT_REF_NAME": branch}
            self.assertEqual(0, run([shell, "scripts/harness/verify-branch.sh"], env=env))
        for branch in ["feat/ATH-1X-foo", "feat/ATH-1-UPPER", "feat/ATH-1-", "feat/ATH-1-a_b"]:
            env = {**os.environ, "CI_COMMIT_REF_NAME": branch}
            self.assertEqual(1, run([shell, "scripts/harness/verify-branch.sh"], env=env))

    def test_commit_summary_is_required(self) -> None:
        shell = find_sh()
        self.assertEqual(0, run([shell, "scripts/harness/verify-commit.sh", "🐛 fix: 검증 강화"]))
        self.assertEqual(1, run([shell, "scripts/harness/verify-commit.sh", "✨ feat: "]))
        self.assertEqual(1, run([shell, "scripts/harness/verify-commit.sh", "✨ feat:   공백 오류"]))


class SecretAndWorklogTests(unittest.TestCase):
    def test_unquoted_secret_is_detected(self) -> None:
        test_path = ROOT / ".harness-secret-contract-test.txt"
        self.assertFalse(test_path.exists(), f"임시 파일이 이미 존재합니다: {test_path}")
        fake_secret = "pass" + "word=" + "abcdefgh"
        try:
            test_path.write_text(fake_secret + "\n", encoding="utf-8")
            self.assertEqual(1, run(quick_check_command()))
        finally:
            test_path.unlink(missing_ok=True)

    def test_worklog_content_must_remain_a_prefix(self) -> None:
        module_path = ROOT / "scripts/harness/verify-worklog.py"
        spec = importlib.util.spec_from_file_location("verify_worklog", module_path)
        self.assertIsNotNone(spec)
        self.assertIsNotNone(spec.loader if spec else None)
        module = importlib.util.module_from_spec(spec)
        assert spec and spec.loader
        spec.loader.exec_module(module)
        self.assertTrue(module.is_append_only(b'{"type":"START"}\n', b'{"type":"START"}\n{"type":"FINISH"}\n'))
        self.assertFalse(module.is_append_only(b'{"type":"START"}\n', b'{"type":"CHANGED"}\n'))
        self.assertFalse(module.is_append_only(b'{"type":"START"}\n', b""))


if __name__ == "__main__":
    unittest.main(verbosity=2)
