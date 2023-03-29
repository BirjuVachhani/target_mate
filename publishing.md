# Publishing

This document defines how to configure project for publishing.

## Android

1. Put `release.jks` file in `android/keystore` directory.

2. Create `keystore.properties` file in `android` directory.

#### Sample `keystore.properties` file.

```properties
KEYSTORE_FILE_PATH=../keystore/release.jks
SIGNING_STORE_PASSWORD=<PASSWORD>
SIGNING_KEY_ALIAS=<ALIAS>
SIGNING_KEY_PASSWORD=<ALIAS_PASSWORD>
```

3. Build release apk or appbundle

```bash
# APK
flutter build apk

# Appbundle
flutter build appbundle
```

## iOS

```
// TODO 🚧
```

## MacOS

1. Build app.

```bash
flutter build macos
```

2. Run `create.sh` installer script to create `dmg` file.

```bash
sh ./installers/dmg/create.sh
```

## Windows

1. Create `.env` file in root of the project with `CERT_PASSWORD` variable.

#### Sample .env file.

```properties
CERT_PASSWORD=<PASSWORD>
```

2. Build app.

```bash
flutter build windows
```

3. Setup for msix creation.

```bash
dart ./installers/msix/setup_local.dart
```

4. Build msix file.

```bash
flutter pub run msix:create
```

6. Restore pubspec.yaml file since msix config is added to it.

```bash
git restore pubspec.yaml
```

## Linux

```
// TODO 🚧
```

## Web
❌ Unsupported.