$inputText = [Console]::In.ReadToEnd()
# .env.example은 허용 대상이므로 먼저 제거하고, 따옴표를 공백으로 바꿔
# "cat .env" 같은 맨 파일명도 경계 검사에 걸리게 한다.
$sanitized = ($inputText -replace '\.env\.example', '') -replace '["'']', ' '

if ($sanitized -match '(?i)(^|[/\\\s=(])\.env([.][a-z0-9_-]+)?([^a-z0-9_.-]|$)|\.(pem|key|p12|jks)([^a-z0-9_-]|$)') {
    Write-Error '차단: Secret 또는 실제 환경 파일을 읽거나 수정할 수 없습니다.'
    exit 2
}

$destructivePattern = @(
    'git\s+reset\s+--hard',
    'git\s+push[^\r\n]*(--force|-f(\s|$))',
    'git\s+clean[^\r\n]*-[a-z]*f',
    'git\s+branch\s+-D(\s|$)',
    'git\s+(checkout|restore)\s+--',
    'rm\s+-[a-z]*r[a-z]*',
    'remove-item[^\r\n]*-(recurse|r)(\s|$)',
    '(rd|rmdir)\s+/s(\s|$)',
    'drop\s+(database|schema|table)',
    'kubectl[^\r\n]*\s+delete'
) -join '|'

if ($inputText -match "(?i)$destructivePattern") {
    Write-Error '차단: 파괴적 Git, 파일, DB 또는 인프라 명령은 승인 없이 실행할 수 없습니다.'
    exit 2
}
