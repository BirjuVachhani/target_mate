fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android release

```sh
[bundle exec] fastlane android release
```

Publishes a new version to the Play store

### android build

```sh
[bundle exec] fastlane android build
```

Build Android apk and app bundle

### android upload

```sh
[bundle exec] fastlane android upload
```

Upload built app bundle to play store

Params



  path:       Path of the App bundle file to upload. [OPTIONAL]

              Defaults to "build/app/outputs/bundle/release/app-release.aab"



Example

  fastlane upload path:app-release.aab

----


## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Publishes a new version to the App Store

### ios build

```sh
[bundle exec] fastlane ios build
```

Builds iOS app

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Uploads built IPA to App Store

Params



  path:        Path of the IPA file to upload. [OPTIONAL]

              Defaults to Runner.ipa



Example

  fastlane upload path:Runner.ipa

### ios certificates

```sh
[bundle exec] fastlane ios certificates
```

Get certificates for local machine

### ios generate_new_certificates

```sh
[bundle exec] fastlane ios generate_new_certificates
```

Generate new certificates

----


## Mac

### mac release

```sh
[bundle exec] fastlane mac release
```

Publishes a new version to the App Store

### mac build_app_store

```sh
[bundle exec] fastlane mac build_app_store
```

Builds macOS app

### mac build_dev_id

```sh
[bundle exec] fastlane mac build_dev_id
```

Builds macOS app

### mac dmg

```sh
[bundle exec] fastlane mac dmg
```

Create dmg

Params



  path:        Path of the app file to upload. [OPTIONAL]

               Defaults to TargetMate.app



Example

  fastlane dmg path:TargetMate.app

### mac notarize_app

```sh
[bundle exec] fastlane mac notarize_app
```

Notarize dmg

Params



  path:        Path of the app file to upload. [OPTIONAL]

               Defaults to TargetMate.app



Example

  fastlane notarize_app path:TargetMate.app

### mac notarize_dmg

```sh
[bundle exec] fastlane mac notarize_dmg
```

Notarize dmg

Params



  path:        Path of the dmg file to upload. [OPTIONAL]

               Defaults to TargetMate.dmg



Example

  fastlane notarize_dmg path:TargetMate.dmg

### mac upload

```sh
[bundle exec] fastlane mac upload
```

Upload built pkg to App Store

Params



  path:        Path of the pkg file to upload. [OPTIONAL]

               Defaults to TargetMate.pkg



Example

  fastlane upload path:TargetMate.pkg

### mac certificates

```sh
[bundle exec] fastlane mac certificates
```

Get certificates for local machine

### mac generate_new_certificates

```sh
[bundle exec] fastlane mac generate_new_certificates
```

Generate new certificates

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).