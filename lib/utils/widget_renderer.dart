import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetRenderer {
  static Future<Uint8List?> render(
    Widget widget, {
    required Size size,
    Duration delay = const Duration(milliseconds: 100),
    Size? logicalSize,
  }) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    // final logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    logicalSize ??= size;

    final RenderView renderView = RenderView(
      window: ui.window,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Material(
            color: Colors.transparent,
            child: Center(child: widget),
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: size.width / logicalSize.width);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}

extension WidgetRendererExtension on Widget {
  Future<Uint8List?> toImage({
    required Size size,
    Duration delay = const Duration(milliseconds: 100),
    Size? logicalSize,
  }) async {
    return WidgetRenderer.render(
      this,
      size: size,
      delay: delay,
      logicalSize: logicalSize,
    );
  }
}
