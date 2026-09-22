@echo off
setlocal

rem Build release APK pointant vers le serveur de production Contabo
rem (signmecy.org), au lieu de l'IP locale utilisee par run_dev.bat.
rem
rem A relancer a chaque nouvelle publication (Play Store, distribution
rem directe, etc.).

echo.
echo API_BASE_URL   : https://api.signmecy.org/api/v1
echo WEB_BASE_URL   : https://signmecy.org
echo REVERB_HOST    : api.signmecy.org (TLS, port 443)
echo.

flutter build apk --release ^
  --dart-define=API_BASE_URL=https://api.signmecy.org/api/v1 ^
  --dart-define=WEB_BASE_URL=https://signmecy.org ^
  --dart-define=REVERB_APP_KEY=cpcqmidjnviw5bmwbtgx ^
  --dart-define=REVERB_HOST=api.signmecy.org ^
  --dart-define=REVERB_PORT=443 ^
  --dart-define=REVERB_USE_TLS=true ^
  --obfuscate --split-debug-info=build/app/outputs/symbols %*
