$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = (Get-Location).Path }
Set-Location $root

# 커밋 유무와 무관하게 동작하도록 status 기반으로 변경 파일을 수집한다.
$changed = git status --porcelain=v1 2>$null | ForEach-Object { $_.Substring(3) }
if (-not $changed) { Write-Output '변경 없음: 빠른 검사 건너뜀'; exit 0 }

# 분 단위 검사(build/bootJar/coverage)는 CI와 verify-all에서만 실행한다.
if ($changed -match '^frontend/') {
    if (Test-Path -LiteralPath 'frontend/node_modules') {
        Push-Location frontend
        try {
            npm run lint; if ($LASTEXITCODE) { exit $LASTEXITCODE }
            npm run test; if ($LASTEXITCODE) { exit $LASTEXITCODE }
        } finally { Pop-Location }
    } else { Write-Output '프런트 검사 건너뜀: npm install이 필요합니다.' }
}

if ($changed -match '^backend/') {
    Push-Location backend
    try { node scripts/gradle.mjs compileTestJava; if ($LASTEXITCODE) { exit $LASTEXITCODE } }
    finally { Pop-Location }
}

Write-Output '변경 영역 빠른 검사 통과'
