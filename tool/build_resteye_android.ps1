[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $repoRoot

if ([string]::IsNullOrWhiteSpace($env:PUB_CACHE)) {
    $env:PUB_CACHE = [Environment]::GetEnvironmentVariable('PUB_CACHE', 'User')
}
if ([string]::IsNullOrWhiteSpace($env:PUB_CACHE)) {
    $env:PUB_CACHE = [Environment]::GetEnvironmentVariable('PUB_CACHE', 'Machine')
}

$pubspecPath = Join-Path $repoRoot 'pubspec.yaml'
$keyPropertiesPath = Join-Path $repoRoot 'android\key.properties'
$flutterApkPath = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-arm64-v8a-release.apk'
$artifactDirectory = Join-Path $repoRoot 'artifacts'

if (-not (Test-Path -LiteralPath $keyPropertiesPath)) {
    throw "Missing android/key.properties. Create the local release signing configuration first."
}

$versionLine = Get-Content -LiteralPath $pubspecPath | Where-Object { $_ -match '^version:\s*\S+' } | Select-Object -First 1
if ($versionLine -notmatch '^version:\s*(?<version>\S+)') {
    throw "Could not read the version from pubspec.yaml."
}
$version = $Matches['version'].Split('+')[0]

$pubCache = $env:PUB_CACHE
if ([string]::IsNullOrWhiteSpace($pubCache)) {
    throw "PUB_CACHE is not set. Configure it on the same drive as this RestEye checkout."
}
if (-not (Test-Path -LiteralPath $pubCache)) {
    throw "PUB_CACHE does not exist: $pubCache"
}

Write-Host "Building RestEye Android arm64 release $version..."
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

& flutter build apk --release --split-per-abi --target-platform android-arm64
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if (-not (Test-Path -LiteralPath $flutterApkPath)) {
    throw "Flutter completed without producing the arm64 APK: $flutterApkPath"
}

New-Item -ItemType Directory -Force -Path $artifactDirectory | Out-Null
$releasePath = Join-Path $artifactDirectory "RestEye-$version-android-arm64-v8a.apk"
Copy-Item -LiteralPath $flutterApkPath -Destination $releasePath -Force

Write-Host "Release artifact: $releasePath"
Get-FileHash -LiteralPath $releasePath -Algorithm SHA256 | Select-Object Algorithm, Hash, Path
