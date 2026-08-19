$inputText = [Console]::In.ReadToEnd()
# .env.example은 허용 대상이므로 먼저 제거하고, 따옴표를 공백으로 바꿔
# "cat .env" 같은 맨 파일명도 경계 검사에 걸리게 한다.
$sanitized = ($inputText -replace '\.env\.example', '') -replace '["'']', ' '

if ($sanitized -match '(?i)(^|[/\\\s=])\.env([.][a-z0-9_-]+)?(\s|$)|\.(pem|key|p12|jks)(\s|$)') {
    Write-Error '차단: Secret 또는 실제 환경 파일을 읽거나 수정할 수 없습니다.'
    exit 2
}

if ($inputText -match '(?i)git\s+reset\s+--hard|git\s+push[^\r\n]*(--force|-f(\s|$))|rm\s+-rf|drop\s+(database|schema)|kubectl[^\r\n]*\s+delete') {
    Write-Error '차단: 파괴적 Git, 파일, DB 또는 인프라 명령은 승인 없이 실행할 수 없습니다.'
    exit 2
}
