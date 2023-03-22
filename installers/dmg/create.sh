#!/bin/sh
test -f "TargetMate.dmg" && rm "TargetMate.dmg"
mv "build/macos/Build/Products/Release/TargetMate.app" "build/macos/Build/Products/Release/Target Mate.app"
create-dmg \
  --volname "Target Mate Installer" \
  --volicon "./installers/dmg/AppIcon.icns" \
  --background "./installers/dmg/background@2x.png" \
  --window-size 600 390 \
  --icon-size 132 \
  --icon "Target Mate.app" 142 180 \
  --hide-extension "Target Mate.app" \
  --app-drop-link 458 180 \
  --hdiutil-quiet \
  "TargetMate.dmg" \
  "build/macos/Build/Products/Release/Target Mate.app"