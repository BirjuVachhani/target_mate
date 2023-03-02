#!/bin/sh
test -f "TogglTarget.dmg" && rm "TogglTarget.dmg"
mv "build/macos/Build/Products/Release/TogglTarget.app" "build/macos/Build/Products/Release/Toggl Target.app"
create-dmg \
  --volname "Toggl Target Installer" \
  --volicon "./installers/dmg/AppIcon.icns" \
  --background "./installers/dmg/background@2x.png" \
  --window-size 600 360 \
  --icon-size 132 \
  --icon "Toggl Target.app" 142 180 \
  --hide-extension "Toggl Target.app" \
  --app-drop-link 458 180 \
  --hdiutil-quiet \
  "TogglTarget.dmg" \
  "build/macos/Build/Products/Release/Toggl Target.app"