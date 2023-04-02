import 'dart:io';

/// Fixes the Pods script to work with the latest version of xCode.
/// See Issue: https://stackoverflow.com/q/63533819
/// See Answer: https://stackoverflow.com/a/75904326
void main() {
  final files = [
    // macOS
    File(
        'macos/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh'),
    // iOS
    File('ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh'),
  ];

  for (final file in files) {
    stdout.writeln('Fixing Pods script: ${file.path}...');
    final content = file.readAsStringSync();
    final newContent = content.replaceAll(r'source="$(readlink "${source}")"',
        r'source="$(readlink -f "${source}")"');
    file.writeAsStringSync(newContent);
  }
  stdout.writeln('Done!');
}
