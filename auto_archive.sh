xcodebuild clean

configuration="Debug"

xcodebuild archive \
-workspace RCE.xcworkspace \
-scheme RCE \
-configuration $configuration
-archivePath "./Build/RCE.xcarchive" \
-allowProvisioningUpdates

xcodebuild \
-exportArchive \
-archivePath "./Build/RCE.xcarchive" \
-exportOptionsPlist "archive.plist" \
-exportPath "./Build" \
-allowProvisioningUpdates
