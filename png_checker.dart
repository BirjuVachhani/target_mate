import 'dart:io';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'dart:isolate';

void main() async {
  final files = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset')
      .listSync()
      .where((file) => path.extension(file.path) == '.png');

  // final files = [File('assets/app_icons/ios.png')];

  List<Future> futures = [];

  for (final file in files) {
    futures.add(Isolate.run(() => processFile(file),
        debugName: path.basename(file.path)));
  }

  Future.wait(futures).then((value) {
    print('done');
  });
}

Future<void> processFile(FileSystemEntity file) async {
  // see if image has a transparent pixel
  final image = await decodeImageFile(file.path);

  if (image == null) {
    print('Could not decode image: ${file.path}');
    throw Exception('Could not decode image: ${file.path}');
  }

  final alphas = image.map((Pixel pixel) {
    final int position = pixel.y * pixel.image.width + pixel.x;
    final int alpha = image.elementAt(position).a.toInt();
    return alpha;
  });

  final transparentAlphas = alphas.where((alpha) => alpha < 255);

  final bool hasTransparentPixel = transparentAlphas.isNotEmpty;

  print(
      '${path.basename(file.path)}: hasTransparentPixel: $hasTransparentPixel} alphas: $transparentAlphas');
}
