# C203 하네스 환경 진단. 온보딩 첫 단계와 훅 이상 의심 시 실행한다.
# 사용: powershell -ExecutionPolicy Bypass -File scripts/harness/doctor.ps1
$fail = $false
function OK($m)  { Write-Output "[OK]   $m" }
function BAD($m) { Write-Output "[FAIL] $m"; $script:fail = $true }

$root = git rev-parse --show-toplevel 2>$null
if ($root) { OK "Git 저장소: $root"; Set-Location $root } else { BAD 'Git 저장소가 아닙니다.' }

# 1. 도구 버전
$nodeV = (node --version) 2>$null
if ($nodeV -and [version]($nodeV.TrimStart('v')) -ge [version]'20.19.0') { OK "Node $nodeV" } else { BAD "Node 20.19 이상이 필요합니다 (현재: $nodeV)" }
$javaV = (java -version) 2>&1 | Select-Object -First 1
if ("$javaV" -match '"21') { OK 'Java 21' } else { BAD "Java 21이 필요합니다: $javaV" }
$pythonV = (python --version) 2>&1
if ($LASTEXITCODE -eq 0 -and "$pythonV" -match '^Python 3\.') { OK "$pythonV" } else { BAD 'Python 3이 필요합니다.' }

# 2. Git Hook 경로
$hooks = git config --get core.hooksPath
if ($hooks -eq '.githooks') { OK 'core.hooksPath=.githooks' } else { BAD 'core.hooksPath가 .githooks가 아닙니다 (npm install 실행).' }

# 3. 의존성 설치 상태
if (Test-Path 'frontend/node_modules') { OK 'frontend/node_modules' } else { BAD 'frontend npm install이 필요합니다.' }

# 4. guard 훅 동작 (차단이 정상)
$powerShellHost = (Get-Process -Id $PID).Path
$guardScript = Join-Path $root '.harness/scripts/guard.ps1'
'{"command":"cat .env"}' | & $powerShellHost -NoProfile -ExecutionPolicy Bypass -File $guardScript 2>$null
if ($LASTEXITCODE -eq 2) { OK 'guard가 .env 접근을 차단합니다.' } else { BAD 'guard가 .env 접근을 차단하지 못했습니다.' }
'{"command":"ls src"}' | & $powerShellHost -NoProfile -ExecutionPolicy Bypass -File $guardScript 2>$null
if ($LASTEXITCODE -eq 2) { BAD 'guard가 정상 명령까지 차단합니다.' } else { OK 'guard가 정상 명령을 통과시킵니다.' }

# 5. Secret 패턴 파일
$p = Get-Content '.harness/secret-patterns.txt' | Where-Object { $_ -and $_ -notmatch '^\s*#' } | Select-Object -First 1
if ($p) { OK 'secret-patterns.txt 패턴 존재' } else { BAD 'secret-patterns.txt에 패턴이 없습니다.' }

Write-Output ''
if (-not $fail) { Write-Output '진단 통과: 하네스 사용 준비 완료.' } else { Write-Output '진단 실패 항목을 해결한 뒤 다시 실행하세요.'; exit 1 }
