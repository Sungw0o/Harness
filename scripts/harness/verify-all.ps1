$root = git rev-parse --show-toplevel
if (-not $root) { throw 'Git 저장소를 찾지 못했습니다.' }

# 브랜치 형식 검사 (verify-branch.sh와 동일 규칙)
$branch = git branch --show-current
$branchPattern = '^(feat|fix|refactor|test|docs|infra|chore|perf|security)/(ATH|LOCAL)-[0-9]+(-[a-z0-9]+)+$'
if ($branch -notin @('main', 'dev') -and $branch -notmatch $branchPattern) {
    Write-Error "[FAIL] 브랜치는 <type>/<ATH|LOCAL>-<num>-<kebab-case> 형식이어야 합니다: $branch"
    exit 1
}

# 커밋 제목 형식 검사 (verify-commit.sh와 동일 규칙)
$message = git log -1 --pretty=%s 2>$null
if ($message) {
    $commitPattern = '^(✨ feat|🐛 fix|♻️ refactor|✅ test|📝 docs|🚀 infra|🔧 chore|⚡️ perf|🔒 security): '
    if ($message -notmatch $commitPattern) {
        Write-Error "[FAIL] 커밋 제목 형식이 올바르지 않습니다: $message"
        exit 1
    }
}

python "$root/scripts/harness/verify-worklog.py" --branch $branch
if ($LASTEXITCODE) { exit $LASTEXITCODE }

& "$root/.harness/scripts/quick-check.ps1"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

Push-Location "$root/frontend"
try {
    npm run lint
    if ($LASTEXITCODE) { exit $LASTEXITCODE }
    npm run test:coverage
    if ($LASTEXITCODE) { exit $LASTEXITCODE }
    npm run build
    if ($LASTEXITCODE) { exit $LASTEXITCODE }
} finally { Pop-Location }

Push-Location "$root/backend"
try {
    node scripts/gradle.mjs test jacocoTestCoverageVerification bootJar
    if ($LASTEXITCODE) { exit $LASTEXITCODE }
} finally { Pop-Location }
