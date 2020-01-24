#!/usr/bin/env bash
flutter clean
flutter build apk --release
flutter build ios --release
cd build/ios/iphoneos/Runner.app/Frameworks
cd App.framework
xcrun bitcode_strip -r app -o app
cd ..
cd Flutter.framework
xcrun bitcode_strip -r Flutter -o Flutter
cd ../../../../../../
exit 0
