# ============================================================================
#  ComfortArch2026.ps1 -> ComfortArch2026.exe 로 빌드하는 도우미
# ----------------------------------------------------------------------------
#  Windows PowerShell 에서 실행하세요. (ps2exe 모듈 사용)
#  아이콘을 쓰려면 같은 폴더에 icon.ico 를 두면 자동으로 적용됩니다.
# ============================================================================

$ErrorActionPreference = 'Stop'

# 1) ps2exe 모듈 설치 (없으면 현재 사용자 범위로 설치)
if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "ps2exe 모듈을 설치합니다..." -ForegroundColor Cyan
    Install-Module -Name ps2exe -Scope CurrentUser -Force
}
Import-Module ps2exe

$here    = $PSScriptRoot
$inFile  = Join-Path $here 'ComfortArch2026.ps1'
$outFile = Join-Path $here 'ComfortArch2026.exe'
$icon    = Join-Path $here 'icon.ico'

$params = @{
    inputFile  = $inFile
    outputFile = $outFile
    noConsole  = $true              # 콘솔 창 숨김 (GUI 전용)
    title      = 'Comfort Arch 2026'
    description = '장난용 화면보호기 (joke screensaver)'
}
if (Test-Path $icon) {
    $params['iconFile'] = $icon
    Write-Host "아이콘 적용: $icon" -ForegroundColor Green
} else {
    Write-Host "icon.ico 가 없어 기본 아이콘으로 빌드합니다. (원하면 icon.ico 를 넣고 다시 실행)" -ForegroundColor Yellow
}

Write-Host "빌드 중..." -ForegroundColor Cyan
Invoke-ps2exe @params

Write-Host "완료: $outFile" -ForegroundColor Green
Write-Host "exe 와 center-photo.png 를 같은 폴더에 두고 실행하세요." -ForegroundColor Green
