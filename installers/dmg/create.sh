#!/bin/sh
test -f "../../Toggl Target.dmg" && rm "../../Toggl Target.dmg"
mkdir -p source_folder
cp -R "../../build/macos/Build/Products/Release/toggl_target.app/" "source_folder/Toggl Target.app"
create-dmg \
  --volname "Toggl Target" \
  --volicon "AppIcon.icns" \
  --background "background@2x.png" \
  --window-size 600 360 \
  --icon-size 132 \
  --icon "Toggl Target.app" 142 180 \
  --hide-extension "Toggl Target.app" \
  --app-drop-link 458 180 \
  "../../Toggl Track.dmg" \
  "source_folder/"
rm -rf "source_folder"