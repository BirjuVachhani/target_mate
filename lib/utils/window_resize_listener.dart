import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:window_manager/window_manager.dart';

import '../resources/keys.dart';

class WindowResizeListener extends WindowListener {
  @override
  void onWindowResized() async {
    final Size size = await windowManager.getSize();
    Hive.box(HiveBoxes.window).put(HiveKeys.width, size.width);
    Hive.box(HiveBoxes.window).put(HiveKeys.height, size.height);
  }

  @override
  void onWindowMoved() async {
    final pos = await windowManager.getPosition();
    Hive.box(HiveBoxes.window).put(HiveKeys.left, pos.dx);
    Hive.box(HiveBoxes.window).put(HiveKeys.top, pos.dy);
  }
}
