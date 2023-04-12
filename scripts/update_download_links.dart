import 'dart:io';

final templateRegex = RegExp(
    r'<!---- DOWNLOAD LINKS START --->(?:.|\n)*.*<!---- DOWNLOAD LINKS END --->');

const String template = '''<!---- DOWNLOAD LINKS START --->

| Platform | Available on Stores                                                                                                                        | Direct Download                                                                                                                                                        |
|----------|--------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Android  | <a href="https://play.google.com/store/apps/details?id=dev.birju.targetmate"><img src=".github/assets/playstore.png" height="70px" /></a>  | <a href="https://github.com/BirjuVachhani/target_mate/releases/download/{{version}}/TargetMate-android-{{version}}.apk"><img src=".github/assets/android.png" height="70px" /></a> |
| iOS      | <a href="https://apps.apple.com/in/app/target-mate/id6447091819"><img src=".github/assets/appstore.png" height="70px" /></a>               | ❌ &nbsp; Not Available                                                                                                                                                |
| macOS    | <a href="https://apps.apple.com/in/app/target-mate/id6447091819"><img src=".github/assets/appstore.png" height="70px" /></a>               | <a href="https://github.com/BirjuVachhani/target_mate/releases/download/{{version}}/TargetMate-macos-{{version}}.dmg"><img src=".github/assets/macos.png" height="70px" /></a>     |
| Windows  | ❌ &nbsp; Not Available                                                                                                                    | <a href="https://github.com/BirjuVachhani/target_mate/releases/download/{{version}}/TargetMate-windows-{{version}}.exe"><img src=".github/assets/windows.png" height="70px" /></a> |
| Linux    | ❌ &nbsp; Not Available                                                                                                                    |  ❌ &nbsp; Not Available                                                                                                                                               |

<!---- DOWNLOAD LINKS END --->''';

/// This script updates the download links in README.md file.
/// It takes a tag as an argument and replaces the {{version}} placeholder
/// with the provided tag.
///
/// Usage: dart scripts/update_download_links.dart 1.0.0
void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Please provide a tag as an argument');
    exit(1);
  }

  final tag = args[0];

  final readme = File('README.md');

  if (!readme.existsSync()) {
    stderr.writeln('README.md does not exist');
    exit(1);
  }

  final content = readme.readAsStringSync();

  final String newTemplate = template.replaceAll('{{version}}', tag);

  if (!templateRegex.hasMatch(content)) {
    stderr.writeln('Template not found in README.md');
    exit(1);
  }

  final updatedContent = content.replaceAll(templateRegex, newTemplate);

  readme.writeAsStringSync(updatedContent);

  stdout.writeln('README.md successfully updated!');
}
