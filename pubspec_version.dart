import 'dart:io';

void main() {
  final file = File('pubspec.yaml');

  final lines = file.readAsLinesSync();

  String versionLine = lines.firstWhere((line) => line.startsWith('version'));

  final version = versionLine.split(':')[1].split('#').first.trim();

  stdout.write(version);
}
