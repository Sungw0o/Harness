$root = git rev-parse --show-toplevel 2>$null
if (-not $root) { $root = (Get-Location).Path }
Set-Location $root

$patternFile = Join-Path $root '.harness/secret-patterns.txt'
$pattern = Get-Content -LiteralPath $patternFile -Encoding UTF8 |
    Where-Object { $_ -and $_ -notmatch '^\s*#' } |
    Select-Object -First 1
if (-not $pattern) {
    Write-Error '검사 실패: .harness/secret-patterns.txt 에서 패턴을 읽지 못했습니다.'
    exit 1
}

$files = @((git diff --name-only), (git diff --cached --name-only), (git ls-files --others --exclude-standard)) | Sort-Object -Unique

foreach ($file in $files) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { continue }
    if ($file -eq '.harness/secret-patterns.txt') { continue }
    if ($file -match '\.(png|jpe?g|gif|jar|class|lock)$') { continue }
    if (Select-String -LiteralPath $file -Pattern "(?i)$pattern" -Quiet) {
        Write-Error "검사 실패: $file 에 하드코딩된 Secret 의심 값이 있습니다."
        exit 1
    }
}

Write-Output '빠른 검사 통과'
