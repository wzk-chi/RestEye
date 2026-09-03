[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $repoRoot

if ([string]::IsNullOrWhiteSpace($env:PUB_CACHE)) {
    $env:PUB_CACHE = [Environment]::GetEnvironmentVariable('PUB_CACHE', 'User')
}

$versionLine = Get-Content -LiteralPath (Join-Path $repoRoot 'pubspec.yaml') |
    Where-Object { $_ -match '^version:\s*\S+' } |
    Select-Object -First 1
if ($versionLine -notmatch '^version:\s*(?<version>\S+)') {
    throw 'Could not read the version from pubspec.yaml.'
}
$version = $Matches['version'].Split('+')[0]

$releaseDirectory = Join-Path $repoRoot 'build\windows\x64\runner\Release'
$artifactDirectory = Join-Path $repoRoot 'artifacts'
$issPath = Join-Path $repoRoot 'tool\RestEye.iss'
$setupIconPath = Join-Path $repoRoot 'windows\runner\resources\app_icon.ico'

if (-not (Test-Path -LiteralPath $setupIconPath)) {
    throw "Windows setup icon was not found: $setupIconPath"
}

if (Get-Process -Name 'rest_eye' -ErrorAction SilentlyContinue) {
    throw 'RestEye is running. Close it before building the Windows release.'
}

$isccCommand = Get-Command 'iscc' -ErrorAction SilentlyContinue
$isccCandidates = @(
    'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
    'C:\Program Files\Inno Setup 6\ISCC.exe',
    (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
)
$isccPath = if ($isccCommand) { $isccCommand.Source } else {
    $isccCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (-not $isccPath) {
    throw 'Inno Setup compiler ISCC.exe was not found.'
}

Write-Host "Building RestEye Windows x64 release $version..."
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
if (-not (Test-Path -LiteralPath (Join-Path $releaseDirectory 'rest_eye.exe'))) {
    throw "Flutter completed without producing the Windows release: $releaseDirectory"
}

New-Item -ItemType Directory -Force -Path $artifactDirectory | Out-Null
Write-Host 'Building the RestEye installer with Inno Setup...'
& $isccPath "/DAppVersion=$version" "/DSourceDir=$releaseDirectory" "/DOutputDir=$artifactDirectory" "/DSetupIconFile=$setupIconPath" $issPath
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$installerPath = Join-Path $artifactDirectory "RestEye-$version-windows-x64-setup.exe"
if (-not (Test-Path -LiteralPath $installerPath)) {
    throw "Inno Setup completed without producing the installer: $installerPath"
}

Write-Host "Release installer: $installerPath"
Get-FileHash -LiteralPath $installerPath -Algorithm SHA256 | Select-Object Algorithm, Hash, Path
