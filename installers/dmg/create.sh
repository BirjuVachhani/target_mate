#!/bin/sh

# This script creates a DMG file from a .app file.
# It uses the create-dmg tool to create the DMG file.
# How to install create-dmg:
#   brew install create-dmg

# How to use this script:
#   1. Run this script from the root of the project to bundle the .app file generated by flutter build command.
#
#   Command:
#   ./installers/dmg/create.sh
#
#  2. Run this script from the root of the project to bundle a .app file provided as a command line argument.
#     This is useful if you want to bundle a .app file that was not generated by flutter build command.
#     e.g. a .app file that is notarized.
#
#   Command:
#   ./installers/dmg/create.sh /path/to/TargetMate.app

# app_name: The name of the .app file to bundle. Change this if you want to use a different name.
# output_file_name: The name of the DMG file to create. Change this if you want to use a different name.
app_name="Target Mate.app"
output_file_name="TargetMate.dmg"

# Check if command line argument is provided
if [ $# -eq 1 ]; then
  # Use command line argument as .app file path
  app_path=$1
  # Check if the .app file exists
  if [ -z "$app_path" ]; then
    echo "Error: Could not find .app file at path $app_path"
    exit 1
  fi
else
  # The directory path where the .app file is located
  app_path="build/macos/Build/Products/Release"

  echo "Finding .app file in path: $app_path"

  # The find command is used to search for the first .app file in the search path.
  # The -print and -quit options are used to print the path of the first match and stop searching.
  # If no match is found, exit with an error.
  app_path=$(find "$app_path" -name "*.app" -print -quit)
  if [ -z "$app_path" ]; then
    echo "Error: Could not find .app file in path $app_path"
    exit 1
  fi
fi

if [ "$app_path" != "$app_name" ]; then
  # Copy the .app file to the current directory and rename it to given $app_name.
  cp -R "$app_path" "./$app_name"
fi

# Check if a dmg already exists. delete it if it does.
test -f "$output_file_name" && rm "$output_file_name"

echo "Creating DMG file from $app_path"

create-dmg \
  --volname "$app_name Installer" \
  --volicon "./installers/dmg/AppIcon.icns" \
  --background "./installers/dmg/background@2x.png" \
  --window-size 600 390 \
  --icon-size 132 \
  --icon "$app_name" 142 180 \
  --hide-extension "$app_name" \
  --app-drop-link 458 180 \
  --hdiutil-quiet \
  "$output_file_name" \
  "./$app_name"

# Delete the copied .app file

rm -R "./$app_name"
