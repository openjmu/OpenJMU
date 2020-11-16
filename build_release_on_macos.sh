#!/usr/bin/env bash

# Define current time
curtime=$(date +%Y-%m-%d\ %H-%M-%S)

# Clean first
flutter clean

# Then run flutter pub get to generate new configuration.
flutter pub get

# Build iOS Runner.app
flutter build ios --release
cd build/ios/iphoneos/Runner.app/Frameworks
cd App.framework
xcrun bitcode_strip -r app -o app
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

# Build Android APK
flutter build apk --release

exit 0
