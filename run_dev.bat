@echo off
setlocal

rem Detecte automatiquement l'adresse IP reseau active de cette machine
rem (celle qui a une passerelle par defaut, donc reellement connectee a
rem internet/au reseau local -- pas les adaptateurs virtuels WSL/VMware)
rem et lance l'app avec cette adresse, sans jamais la taper a la main.
rem Utile si tu changes de reseau Wi-Fi ou de hotspot souvent : relance
rem simplement ce script a chaque fois.

for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1).IPv4Address.IPAddress"') do set LAN_IP=%%i

if "%LAN_IP%"=="" (
  echo [ERREUR] Impossible de detecter l'adresse IP reseau actuelle.
  echo Verifie que le Wi-Fi est bien connecte, puis reessaye.
  exit /b 1
)

echo.
echo Adresse detectee : %LAN_IP%
echo API_BASE_URL      : http://%LAN_IP%:8000/api/v1
echo.
echo Rappel : le serveur Laravel doit tourner sur cette meme adresse
echo   ^(php artisan serve --host=0.0.0.0 --port=8000^)
echo et le pare-feu Windows doit autoriser le port 8000 en entree.
echo.

flutter run --dart-define=API_BASE_URL=http://%LAN_IP%:8000/api/v1 %*
