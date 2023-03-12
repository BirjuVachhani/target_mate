import 'dart:io';

import 'package:screwdriver/screwdriver_io.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stdout.writeln(
        'Usage: dart setup.dart path/to/config/file.yaml CERT_PASSWORD');
    exit(0);
  }

  if (args.length == 1) {
    stderr.writeln('Cert password is not provided.');
    exit(1);
  }

  final String path = args.first;
  final File configFile = File(path);

  if (!configFile.existsSync()) {
    stderr.writeln('Config file not found at path: $path');
    exit(1);
  }

  final String password = args[1];

  String configContent = configFile.readAsStringSync();

  configContent = configContent.replaceAll('{{ password }}', password);

  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln(
        'Pubspec file not found. Make sure this is running from the project root directory!');
    exit(1);
  }

  pubspecFile.appendStringSync('\n\n$configContent');
}
