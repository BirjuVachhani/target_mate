import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TargetMateAppIcon extends StatelessWidget {
  final double size;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const TargetMateAppIcon({
    super.key,
    this.size = 1024,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  factory TargetMateAppIcon.platform({
    Key? key,
    double size = 1024,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Color? color,
    Color? backgroundColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TargetMateAppIcon(
          key: key,
          size: size,
          borderRadius: borderRadius,
          shape: shape,
          color: color,
          backgroundColor: backgroundColor,
          padding: padding,
          margin: margin,
        );
      case TargetPlatform.macOS:
        return TargetMateAppIcon(
          key: key,
          size: size,
          borderRadius: BorderRadius.circular(196),
          shape: BoxShape.rectangle,
          color: color,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(100),
          margin: const EdgeInsets.all(107),
        );
      case TargetPlatform.iOS:
        return TargetMateAppIcon(
          key: key,
          size: size,
          borderRadius: BorderRadius.zero,
          shape: BoxShape.rectangle,
          color: color,
          backgroundColor: backgroundColor,
          padding: padding,
          margin: EdgeInsets.zero,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final margin = this.margin ?? EdgeInsets.zero;
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Container(
          width: 1024,
          height: 1024,
          padding: margin,
          alignment: Alignment.center,
          child: Container(
            width: 1024 - margin.horizontal,
            height: 1024 - margin.vertical,
            padding: padding ?? const EdgeInsets.all(130),
            decoration: BoxDecoration(
              shape: shape,
              color: backgroundColor ?? const Color(0xFF02080D),
              borderRadius: borderRadius ?? BorderRadius.circular(196),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'assets/app_icon_inner.png',
                fit: BoxFit.fitWidth,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
