@echo off
call flutter clean
call flutter pub get
call fgen -o lib/constants/resources.dart --no-preview --no-watch
call ff_route
call flutter build apk --release
pause
