import 'dart:io';

import 'package:collection/collection.dart';
import 'package:screwdriver/screwdriver_io.dart';

void main() {
  final String? fromEnv = loadPasswordFromEnv();
  if (fromEnv == null) {
    stderr.writeln('Cert password not found in env file.');
    exit(1);
  }

  final String password = fromEnv;

  final File configFile = File('installers/msix/local.yaml');

  if (!configFile.existsSync()) {
    stderr.writeln('Config file not found at path: local.yaml');
    exit(1);
  }

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

String? loadPasswordFromEnv() {
  final file = File('.env');

  if (!file.existsSync()) {
    return null;
  }

  final List<String> lines = file.readAsLinesSync();

  final String? password = lines
      .firstWhereOrNull((line) =>
          line.contains('CERT_PASSWORD') &&
          line.contains('=') &&
          !line.endsWith('='))
      ?.split('=')
      .lastOrNull
      ?.trim();

  if (password == null) return null;
  if (password.trim().isEmpty) return null;

  return password;
}
