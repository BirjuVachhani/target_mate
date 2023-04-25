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

Params



  generate:   Whether to generate new certificates if required. [OPTIONAL]

              Defaults to false



Example

  fastlane certificates generate:true

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

Params



  fast:   Whether to skip rebuilding with xcode. [OPTIONAL]

          Defaults to false



Example

  fastlane release fast:true

### mac release_dev_id

```sh
[bundle exec] fastlane mac release_dev_id
```

Release a new notarized DevID build

### mac build_app_store

```sh
[bundle exec] fastlane mac build_app_store
```

Builds macOS app

Params



  fast:   Whether to skip rebuilding with xcode. [OPTIONAL]

          Defaults to false



Example

  fastlane build_app_store fast:true

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

               Defaults to ARTIFACT_NAME.app



Example

  fastlane dmg path:ARTIFACT_NAME.app

### mac notarize_app

```sh
[bundle exec] fastlane mac notarize_app
```

Notarize app

Params



  path:        Path of the app file to upload. [OPTIONAL]

               Defaults to ARTIFACT_NAME.app



Example

  fastlane notarize_app path:ARTIFACT_NAME.app

### mac upload

```sh
[bundle exec] fastlane mac upload
```

Upload built pkg to App Store

Params



  path:        Path of the pkg file to upload. [OPTIONAL]

               Defaults to ARTIFACT_NAME.pkg



Example

  fastlane upload path:ARTIFACT_NAME.pkg

### mac pkg

```sh
[bundle exec] fastlane mac pkg
```

Create a signed pkg file from the built .app

Params



  path:        Path of the .app file to upload. [OPTIONAL]

               Defaults to ARTIFACT_NAME.app



Example

  fastlane pkg path:ARTIFACT_NAME.pkg

### mac certificates

```sh
[bundle exec] fastlane mac certificates
```

Get certificates for local machine

Params



  generate:   Whether to generate new certificates if required. [OPTIONAL]

              Defaults to false



Example

  fastlane certificates generate:true

### mac generate_new_certificates

```sh
[bundle exec] fastlane mac generate_new_certificates
```

Generate new certificates

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
