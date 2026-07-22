# Répare "Error: Unable to determine engine version..." sur Windows
# Usage (PowerShell) : .\tool\repair_flutter_engine.ps1

$ErrorActionPreference = "Stop"

$flutterRoot = "C:\flutter\flutter"
if (-not (Test-Path "$flutterRoot\bin\flutter.bat")) {
    Write-Host "Flutter introuvable à $flutterRoot — modifiez `$flutterRoot dans ce script."
    exit 1
}

Write-Host "SDK Flutter : $flutterRoot"

# 1. Débloquer les scripts PowerShell du SDK
Get-ChildItem "$flutterRoot\bin\internal\*.ps1" | ForEach-Object {
    Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
}

# 2. Lire la version moteur officielle
$engineFile = "$flutterRoot\bin\internal\engine.version"
if (-not (Test-Path $engineFile)) {
    Write-Host "Fichier manquant : $engineFile"
    Write-Host "Réinstallez Flutter : https://docs.flutter.dev/get-started/install/windows"
    exit 1
}
$engineVersion = (Get-Content $engineFile -Raw).Trim()
Write-Host "Engine version : $engineVersion"

# 3. Écrire le cache attendu par flutter.bat
$cacheDir = "$flutterRoot\bin\cache"
New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$cacheDir\engine.stamp", $engineVersion, $utf8)
[System.IO.File]::WriteAllText("$cacheDir\engine.realm", "", $utf8)
Write-Host "OK : bin/cache/engine.stamp mis à jour"

# 4. Tester flutter
$env:FLUTTER_PREBUILT_ENGINE_VERSION = $engineVersion
& "$flutterRoot\bin\flutter.bat" --version
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "flutter --version a échoué. Vérifiez :"
    Write-Host "  - Git installé (git --version)"
    Write-Host "  - git update-git-for-windows"
    Write-Host "  - PowerShell : Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Réparation terminée. Relancez : flutter run"
