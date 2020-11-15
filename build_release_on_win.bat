@echo off
start cmd /c flutter clean
echo "Run next after cleaned."
pause
flutter build apk --release
pause