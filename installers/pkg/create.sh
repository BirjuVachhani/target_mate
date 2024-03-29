# How to use this script:
#   1. Run this script from the root of the project to bundle the .app file generated by flutter build command.
#
#   Command:
#   ./scripts/package.sh
#
#  2. Run this script from the root of the project to bundle a .app file provided as a command line argument.
#     This is useful if you want to bundle a .app file that was not generated by flutter build command.
#     e.g. a .app file that is notarized.
#
#   Command:
#   ./installers/pkg/create.sh /path/to/TargetMate.app

# app_name: The name of the .app file to bundle. Change this if you want to use a different name.
# output_file_name: The name of the DMG file to create. Change this if you want to use a different name.
app_name="TargetMate.app"
output_file_name="TargetMate.pkg"
installer_cert_name="3rd Party Mac Developer Installer: Birju Vachhani (TQ37FM6DBD)"

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

# Check if a pkg already exists. delete it if it does.
test -f "$output_file_name" && rm "$output_file_name"

# Check if a unsigned.pkg already exists. delete it if it does.
test -f "unsigned.pkg" && rm "unsigned.pkg"

echo "Bundling to unsigned.pkg"
xcrun productbuild --component "$app_name" /Applications/ unsigned.pkg

echo "Signing unsigned.pkg"
xcrun productsign --sign "$installer_cert_name" unsigned.pkg "$output_file_name"

echo "Removing unsigned.pkg"
rm -rf unsigned.pkg

echo "Done!"

# Original Script
# APP_NAME=$(find $(pwd) -name "*.app")
# PACKAGE_NAME=$(basename "$APP_NAME" .app).pkg
# xcrun productbuild --component "$APP_NAME" /Applications/ unsigned.pkg
#
# INSTALLER_CERT_NAME=$(keychain list-certificates \
#           | jq '[.[]
#             | select(.common_name
#             | contains("Mac Developer Installer"))
#             | .common_name][0]' \
#           | xargs)
# xcrun productsign --sign "$INSTALLER_CERT_NAME" unsigned.pkg "$PACKAGE_NAME"
# rm -f unsigned.pkg
