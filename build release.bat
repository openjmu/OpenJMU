@echo off
start cmd /c flutter clean -v
pause
flutter build apk --release -v
pause