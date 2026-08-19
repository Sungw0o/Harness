#!/usr/bin/env sh
set -eu
root="$(git rev-parse --show-toplevel)"
exec python "$root/scripts/harness/task-log.py" start "$@"
