#!/usr/bin/env bash

flutter --version

# Define current time
curtime=$(date +%Y-%m-%d\ %H-%M-%S)

# Clean first
flutter clean

# Then run flutter pub get to generate new configuration.
flutter pub get

# Regenerate resources and routes.
fgen -o lib/constants/resources.dart --no-preview --no-watch
ff_route

# Build Android APK
flutter build apk --release

## Pod install
cd ios
pod install
cd ..

# Build iOS Runner.app
flutter build ios --release
cd build/ios/iphoneos/Runner.app/Frameworks
cd App.framework
xcrun bitcode_strip -r App -o App
cd ..
cd Flutter.framework
xcrun bitcode_strip -r Flutter -o Flutter
cd ../../../../../../

# Archive Runner.app
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner clean archive -configuration release \
  -sdk iphoneos -archivePath build/ios/Runner.xcarchive \
  -quiet

# Export IPA
xcodebuild -exportArchive -archivePath build/ios/Runner.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath release/"Runner $curtime" \
  -quiet

exit 0
