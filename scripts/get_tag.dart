import 'dart:io';

/// A script that takes two workflow tag params in input and outputs the
/// one that is not empty.
///
/// Usage: Build workflows in this repository are workflow dispatch events
/// with tag parameter or triggered by a Github release.
///
/// A tag is required later in the workflow to rename release artifacts and
/// upload to a Github release.
///
/// This script is used to get the tag from the workflow dispatch event or
/// from the Github release. By design, the workflow will either have an input
/// tag or a Github release tag, but not both. Since there is no documented
/// way to get the Github release tag conditionally in a workflow,
/// this script is used to get the tag from the workflow dispatch event or
/// from the Github release.
///
/// How to use in a workflow:
///
/// Command:
///   dart scripts/get_tag.dart ${{ github.event.inputs.tag }} ${{ github.ref }}
///
/// Running the command above will output the tag to console or stdout.
void main(List<String> args) {
  final tags = args
      .map(
        (item) => item
            .replaceAll(RegExp(r'null', caseSensitive: false), '')
            .replaceAll(RegExp(r'undefined', caseSensitive: false), '')
            .replaceAll('refs/tags/', '')
            .trim(),
      )
      .where((item) => item.isNotEmpty);

  if (tags.isEmpty) {
    stderr.writeln('No tag found in args. Must provide at least one tag.');
    exit(1);
  }

  // if (tags.length > 1) {
  //   stderr
  //       .writeln('More than one tag found in args. Must provide only one tag.');
  //   exit(1);
  // }

  stdout.write(tags.first.trim());
}
