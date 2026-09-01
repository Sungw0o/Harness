#!/usr/bin/env sh
set -eu
root="$(git rev-parse --show-toplevel)"
sh "$root/scripts/harness/verify-branch.sh"
sh "$root/scripts/harness/verify-commit.sh"
python "$root/scripts/harness/verify-worklog.py"
python "$root/scripts/harness/test-harness.py"
sh "$root/.harness/scripts/quick-check.sh"
(cd "$root/frontend" && npm run lint && npm run test:coverage && npm run build)
(cd "$root/backend" && node scripts/gradle.mjs test jacocoTestCoverageVerification bootJar)
