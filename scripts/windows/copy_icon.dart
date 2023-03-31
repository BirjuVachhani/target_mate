import 'dart:io';

import '../pubspec_version.dart';

void main() {
  final iconFile = File('windows/runner/resources/app_icon.ico');

  final version = retrievePubspecVersion();

  final dest = File('dist/$version/app_icon.ico');

  dest.createSync(recursive: true);

  final bytes = iconFile.readAsBytesSync();
  dest.writeAsBytesSync(bytes);
}
