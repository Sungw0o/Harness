import { spawnSync } from 'node:child_process'
import { existsSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import process from 'node:process'

const command = process.platform === 'win32' ? 'gradlew.bat' : './gradlew'
const backendDir = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const repoRoot = resolve(backendDir, '..')
let workingDir = backendDir
let mappedDrive

if (process.platform === 'win32' && /[^\x00-\x7F]/.test(repoRoot)) {
  mappedDrive = ['Z:', 'Y:', 'X:', 'W:'].find((drive) => !existsSync(`${drive}\\`))
  if (!mappedDrive) {
    console.error('Gradle 실행용 임시 드라이브 문자를 찾지 못했습니다.')
    process.exit(1)
  }

  const mapping = spawnSync('subst', [mappedDrive, repoRoot], { shell: true })
  if (mapping.status !== 0) process.exit(mapping.status ?? 1)
  workingDir = `${mappedDrive}\\backend`
}

let result
try {
  result = spawnSync(command, process.argv.slice(2), {
    cwd: workingDir,
    env: mappedDrive
      ? { ...process.env, GRADLE_USER_HOME: `${mappedDrive}\\.gradle-user-home` }
      : process.env,
    shell: process.platform === 'win32',
    stdio: 'inherit',
  })
} finally {
  if (mappedDrive) spawnSync('subst', [mappedDrive, '/D'], { shell: true })
}

process.exit(result.status ?? 1)
