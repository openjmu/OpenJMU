@echo off
start cmd /c flutter clean -v
echo "Run next after cleaned."
pause
flutter build apk --release -v
pause