import 'package:flutter/widgets.dart';

class RectClipper extends CustomClipper<Rect> {
  final double start;
  final double end;

  RectClipper({this.start = 0, required this.end});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      start * size.width,
      0,
      end * size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant RectClipper oldClipper) =>
      oldClipper.start != start || oldClipper.end != end;
}
