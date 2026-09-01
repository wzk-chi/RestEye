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

$flutterApkPath = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk'
$artifactDirectory = Join-Path $repoRoot 'artifacts'

Write-Host "Building RestEye Android arm64 debug $version..."
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& flutter build apk --debug --split-per-abi --target-platform android-arm64
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if (-not (Test-Path -LiteralPath $flutterApkPath)) {
    throw "Flutter completed without producing the debug APK: $flutterApkPath"
}

New-Item -ItemType Directory -Force -Path $artifactDirectory | Out-Null
$debugPath = Join-Path $artifactDirectory "RestEye-$version-android-arm64-v8a-debug.apk"
Copy-Item -LiteralPath $flutterApkPath -Destination $debugPath -Force

Write-Host "Debug artifact: $debugPath"
Get-FileHash -LiteralPath $debugPath -Algorithm SHA256 | Select-Object Algorithm, Hash, Path
