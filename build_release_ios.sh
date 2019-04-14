flutter build ios --release
rm -rf OpenJmu.app
cp -r ./build/ios/iphoneos/Runner.app ./Distribution/OpenJmu.app
rm -rf OpenJmu
mkdir ./Distribution/OpenJmu
mkdir ./Distribution/OpenJmu/Payload
cp -r ./Distribution/OpenJmu.app ./Distribution/OpenJmu/Payload/OpenJmu.app
cp ./Distribution/Icon.png ./Distribution/OpenJmu/iTunesArtwork
cd ./Distribution/OpenJmu
zip -r OpenJmu.ipa Payload iTunesArtwork
cd ../../
flutter clean
exit 0